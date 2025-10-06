<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:cc="http://creativecommons.org/ns#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:time="http://www.vionta.net/schema/project/timming/1.0"
    xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
    xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
    >
  
  <xsl:output method="xml" indent="yes" ></xsl:output>

  <xsl:variable name="months" >
    <months>
      <m name="ENE" key="01" days="31" next="02" plusYear3="0" />
      <m name="FEB" key="02" days="29" next="03" plusYear3="0"/>
      <m name="MAR" key="03" days="31" next="04" plusYear3="0"/>
      <m name="ABR" key="04" days="30" next="05" plusYear3="0"/>
      <m name="MAY" key="05" days="31" next="06" plusYear3="0"/>
      <m name="JUN" key="06" days="30" next="07" plusYear3="0"/>
      <m name="JUL" key="07" days="31" next="08" plusYear3="0"/>
      <m name="AGO" key="08" days="31" next="09" plusYear3="0"/>
      <m name="SEPT" key="09" days="30" next="10" plusYear3="0"/>
      <m name="OCT" key="10" days="31" next="11" plusYear3="0"/>
      <m name="NOV" key="11" days="30" next="12" plusYear3="0"/>
      <m name="DIC" key="12" days="31" next="01" plusYear3="1"/>
    </months>
  </xsl:variable>

  <xsl:param name="mainWidth" select="800 + 10" /> 
  <xsl:param name="minDate"
	     select="xsd:date(sort(//initDate/text())[1])" />
  <xsl:param name="startMonth"
	     select="month-from-date($minDate)" /> 
  <xsl:param name="maxDate"
	     select="xsd:date(sort(//endDate/text())[last()])" />
  <xsl:param name="totalDaysSpan"
	     select="days-from-duration($maxDate - $minDate)" />
  <xsl:param name="dayFactor"
	     select="round($mainWidth div $totalDaysSpan )" />
  <xsl:param name="line-height"
	     select="38" />
  <xsl:param name="top-panel"
	     select="90" />
  <xsl:param name="mainHeight" select="count(//*:task) * $line-height + $top-panel + 30" />
  <xsl:param name="left-side-panel" select="180" />

  <!-- Number of width pixels per day -->
  <xsl:param name="weekendDayFactor"
	     select="$dayFactor" />
  <!-- Number of width pixels per day including a 7/5
       compensation factor for weekend days. Not needed
       if final dates are provided, only when duration is
       requested -->
  <xsl:param name="current-date-days" select="days-from-duration(current-date() - $minDate)" />

  <xsl:template match="/"> 
    <svg
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:cc="http://creativecommons.org/ns#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns="http://www.w3.org/2000/svg"
	xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
	xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
	width="{$mainWidth + 100}px"
	height="{$mainHeight}px"
	viewBox="0 0 {$mainWidth + 100} {$mainHeight}"
	version="1.1"
	>

      <xsl:comment>
	DEBUG| Min Date : <xsl:value-of select="$minDate" /> 
	DEBUG| Max Date :<xsl:value-of select="$maxDate"  />
	DEBUG| Day Span :<xsl:value-of select="$totalDaysSpan" />
      </xsl:comment>

      <svg:g id="bluebar">
	<xsl:call-template name="background-lines" />
	<xsl:call-template name="main-ruler" />
	<xsl:call-template name="current-date-mark" />	
	<xsl:call-template name="main-average" />	
	<xsl:apply-templates/>
      </svg:g>
    </svg>   
  </xsl:template>

  <!--
      ......... TASK ...........
  -->
  <xsl:template match="task" >

    <!-- ............ Con Fecha ............... -->
    <xsl:if
	test="( ./timming/initDate/text()!='' )
	      and (./timming/endDate/text() != '' )" >

      <xsl:variable
	  name="taskWidth"
	  select="round(
		  $weekendDayFactor * days-from-duration(
		  xsd:date(timming/endDate/text())  - xsd:date(timming/initDate/text())))" />

      <xsl:variable
	  name="taskStart"
	  select="10 + round(
		  $weekendDayFactor * 
		  days-from-duration(xsd:date(timming/initDate/text()) - $minDate) )" />


      <!-- Task bar .................. -->
      <svg:rect
	  style="opacity:0.744;fill:#121244;fill-opacity:1;stroke:none;stroke-width:1.60000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
	  id="meses"
	  width="{$taskWidth}"
	  height="14"
	  x="{$taskStart + $left-side-panel}" 
	  y="{(count(preceding-sibling::*) + 1)* $line-height + $top-panel}" />

      <xsl:choose>
	<xsl:when test="(timming/advance > 0) and (100 >= timming/advance)" >
	  <svg:rect
	      style="opacity:0.744;fill:#66bb66;fill-opacity:1;stroke:none;stroke-width:1.60000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
	      id="meses"
	      width="{$taskWidth * (timming/advance div 100)}"
	      height="6"
	      x="{$taskStart + $left-side-panel}" 
	      y="{(count(preceding-sibling::*) + 1)* $line-height + $top-panel + 4}" />
	</xsl:when>
	
	<xsl:otherwise>
	</xsl:otherwise>
      </xsl:choose>
      
      <!-- Task Name .................. -->
      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:bold;font-size:12px;line-height:125%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#000033;fill-opacity:1;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="{$taskStart - 5 + $left-side-panel}"
	  y="{(count(preceding-sibling::*) + 1)* $line-height + $top-panel - 5}"
	  id="text{@days}{count(preceding-sibling::*)} "
	  >	
	<xsl:value-of select="name/text()" ></xsl:value-of>
      </svg:text>
      
      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:normal;font-size:12px;line-height:125%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#000033;fill-opacity:1;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="15"
	  y="{(count(preceding-sibling::*) + 1)* $line-height + $top-panel - 5}"
	  id="text{@days}{count(preceding-sibling::*)} "
	  ><xsl:value-of select="name/text()" /></svg:text>

      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:normal;font-size:9px;line-height:125%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#121233;fill-opacity:1;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="15"
	  y="{(count(preceding-sibling::*) + 1.5 ) * $line-height + $top-panel -5 }"
	  id="text{@days}{count(preceding-sibling::*)} "
	  ><xsl:value-of select="substring(timming/initDate/text(), 6, 10)" ></xsl:value-of>
      </svg:text>

      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:normal;font-size:9px;line-height:125%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#121233;fill-opacity:1;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="40"
	  y="{(count(preceding-sibling::*) + 1.5 ) * $line-height + $top-panel - 5}"
	  id="text{@days}{count(preceding-sibling::*)} "
	  >- <xsl:value-of select="substring(timming/endDate/text(), 6,10)" ></xsl:value-of>
      </svg:text>

      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:normal;font-size:9px;line-height:125%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#121233;fill-opacity:1;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="65"
	  y="{(count(preceding-sibling::*) + 1.5 ) * $line-height +  $top-panel - 5}"
	  id="text{@days}{count(preceding-sibling::*)} "
	  > 
	<xsl:if test="boolean(timming/advance/text())" >
	<xsl:value-of select="timming/advance/text()"  />%</xsl:if>
      </svg:text>


    </xsl:if>

    <!-- ............. Caso alternativo : Sin fecha .............. -->
    <xsl:if
	test="not( ./timming/initDate/text()!='' )
	      or not(./timming/endDate/text() != '' )" >

      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:bold;font-size:12px;line-height:125%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#666666;fill-opacity:0.7;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="20"
	  y="{(count(preceding-sibling::*) + 1)* $line-height  +  $top-panel - 5 }"
	  id="text{@days}{count(preceding-sibling::*)} "
	  >	
	<xsl:value-of select="name/text()" ></xsl:value-of>
      </svg:text>

    </xsl:if>

    
    <svg:path
	style="opacity:0.5;fill:#006e18;fill-opacity:1;stroke:none;stroke-width:1.60000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
	d="m {(100.02967 + (4 * @days))} ,58.43359 c -5.28223,-2e-4 -9.56437,3.87688 -9.56412,8.65944 -0.0452,2.25444 0.57853,3.52104 1.18588,4.81263 l 8.33371,11.34483 8.16237,-11.34483 c 0.91804,-1.58432 1.44089,-2.83345 1.44342,-4.81263 2.5e-4,-4.78155 -4.28015,-8.65822 -9.56126,-8.65944 z"
	id="path{@days}"
	inkscape:connector-curvature="0"
	sodipodi:nodetypes="ccccccc" 
	onclick="alert(this)"
	>
    </svg:path>

  </xsl:template>


  <!--
      ......... Milestone ...........
  -->
  <xsl:template match="*:milestone" >

    <!-- ............ Con Fecha ............... -->
    <xsl:if
	test="./timming/date/text()!=''" >

      <xsl:variable
	  name="taskStart"
	  select="20 +  round(
		  $weekendDayFactor * 
		  days-from-duration(xsd:date(timming/date/text()) - $minDate) )" />

      <svg:path d="M {$taskStart + $left-side-panel} 72 l 8 12 l -16 0 Z"
		style="opacity:0.744;fill:#0000ff;fill-opacity:1;stroke:none;stroke-width:1.60000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
		id="date"
		/>
      
      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:bold;font-size:12px;lien-height:125%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#000033;fill-opacity:1;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="{$taskStart + 5 + $left-side-panel}"
	  y="{80}"
	  id="text{@days}{count(preceding-sibling::*)} "
	  transform="rotate(-45,{$taskStart + 5 + $left-side-panel},80)"
	  >	
	<xsl:value-of select="name/text()" ></xsl:value-of>
      </svg:text>

    </xsl:if>
  </xsl:template>
  
  <!-- ...... Main Ruler ......... -->
  <xsl:template name="main-ruler" >
    <svg:rect
	style="opacity:1;fill:#708ade;fill-opacity:1;stroke:none;stroke-width:1.60000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
	id="meses"
	width="{$mainWidth + $left-side-panel}"
	height="14"
	x="10.25478" 
	y="86.31613" />
  </xsl:template>

  <!--
      ......... Background Lines ...........
  -->
  <xsl:template name="background-lines" >
    <xsl:choose >
      <xsl:when test="60 > $totalDaysSpan  ">
	<xsl:call-template name="short-background" />
      </xsl:when>
      <xsl:when test="150 > $totalDaysSpan ">
	<xsl:call-template name="medium-background" />
      </xsl:when>
      <xsl:otherwise >
	<xsl:call-template name="long-background" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ...... Short Background ....... -->
  <xsl:template name="short-background" >
    <xsl:variable
	name="barShift"
	select="(30 - day-from-date(xsd:date($minDate) ))" />
<!--
    select="10 + round(
    $weekendDayFactor * 
    days-from-duration(xsd:date(timming/initDate/text()) - $minDate) )" />
-->

    
    <xsl:call-template name="month-line-mark" >
      <xsl:with-param name="shift" select="$barShift" />
    </xsl:call-template>

    <xsl:call-template name="fiveteen-day-line-mark" >
      <xsl:with-param name="shift" select="($barShift + 15)" />
    </xsl:call-template>

  </xsl:template>

  <!-- ...... Month line Mark ........ -->
  <xsl:template name="month-line-mark" >
    <xsl:param name="shift" />
    <xsl:if test="$mainWidth > ($shift * $dayFactor)" >
      <svg:rect
	  style="opacity:1;fill:#e9e7de;fill-opacity:1;stroke:none;stroke-width:0.90000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
	  id="m1"
	  width="2"
	  height="{$mainHeight}"
	  x="{($shift * $dayFactor) + $left-side-panel + 10}" 
	  y="10" />
      <xsl:variable name="current-month-shift" select=" ($startMonth + round($shift div 30.5)) " />
      <xsl:variable name="current-month" select="(number($current-month-shift) - (floor($current-month-shift div 12 ) * 12)) " />
      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:bold;font-size:14px;line-height:100%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#b8b2a5;fill-opacity:0.6;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="{($shift * $dayFactor) + $left-side-panel + 10}" 
	  y="20"
	  id="m-namet{$current-month}"
	  >	
	<xsl:value-of
	    select="$months//m[$current-month]/@name" ></xsl:value-of>
      </svg:text>
      
      <xsl:if test=" $current-month = 0" >
	
      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:bold;font-size:14px;line-height:100%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#b8b2a5;fill-opacity:0.6;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="{($shift * $dayFactor) + $left-side-panel  + 10}" 
	  y="20"
	  id="m-namet{$current-month}"
	  >
	<xsl:value-of
	    select="$months//m[12]/@name" ></xsl:value-of>
      </svg:text>
      </xsl:if>
      <xsl:call-template name="month-line-mark" >
	<xsl:with-param name="shift" select="($shift + 30)" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ....... Fiveteen day mark ........ -->  
  <xsl:template name="fiveteen-day-line-mark" >
    <xsl:param name="shift" />
    <xsl:if test="$mainWidth > ($shift * $dayFactor)" >
      <svg:rect
	  style="opacity:1;fill:#e9e7de;fill-opacity:1;stroke:none;stroke-width:1.60000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
	  id="m2"
	  width="1"
	  height="{$mainHeight}"
	  x="{($shift * $dayFactor) + $left-side-panel + 10}" 
	  y="10" />
      <xsl:call-template name="fiveteen-day-line-mark" >
	<xsl:with-param name="shift" select="($shift + 30)" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!-- ......... Medium Background .......... -->
  <xsl:template name="medium-background" >
    <xsl:variable
	name="taskWidth"
	select="round(
		$weekendDayFactor * 
		$months/months/m[month-from-date($minDate)+2]/@days  )" />
    <xsl:variable
	name="taskStart"
	select="20  +  round(
		$weekendDayFactor * 
		days-from-duration(
		xsd:date(concat(
		year-from-date($minDate), '-' , 
		$months/months/m[month-from-date($minDate)+1]/@key, '-01'))
		- $minDate) )" />
    <xsl:call-template name="month-block-mark" >
      <xsl:with-param name="shift"
		      select="(30 - day-from-date(xsd:date($minDate) ))" />
    </xsl:call-template>
  </xsl:template>

  <!-- .......... Month block ............ -->
  <xsl:template name="month-block-mark" >
    <xsl:param name="shift" />
    <xsl:if test="$mainWidth > ($shift * $dayFactor)" >
      <svg:rect
	  style="opacity:1;fill:#f6f2ff;fill-opacity:1;stroke:none;stroke-width:1.60000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
	  id="m1"
	  width="{(30 * $dayFactor) + 10}"
	  height="{$mainHeight}"
	  x="{($shift * $dayFactor) + $left-side-panel}" 
	  y="10" />
      <xsl:variable name="current-month-shift" select=" ($startMonth + round($shift div 30)) " />
      <xsl:variable name="current-month" select="(number($current-month-shift) -  (floor($current-month-shift div 12 ) * 12)) " />
      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:bold;font-size:14px;line-height:100%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#8888aa;fill-opacity:0.6;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="{($shift * $dayFactor) - 5 + $left-side-panel + 10}" 
	  y="20"
	  id="m-namet{$current-month}"
	  >	
	<xsl:value-of
	    select="$months//m[$current-month]/@name" />
      </svg:text>
      <xsl:if test="0 = $current-month" >
      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:bold;font-size:14px;line-height:100%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#8888aa;fill-opacity:0.6;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="{($shift * $dayFactor) - 5 + $left-side-panel}" 
	  y="20"
	  id="m-namet{$current-month}"
	  >	
	<xsl:value-of
	    select="$months//m[12]/@name" />
      </svg:text>
      </xsl:if>
      
      <xsl:call-template name="month-block-mark" >
	<xsl:with-param name="shift" select="$shift + 60" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ..... Long Background ... -->
  <xsl:template name="long-background" >
    <xsl:variable
	name="barShift"
	select="(30 - day-from-date(xsd:date($minDate) ))" />
    <xsl:comment>|DEBUG: Short line break : <xsl:value-of select="$barShift" ></xsl:value-of></xsl:comment>
    
    <xsl:call-template name="month-line-mark" >
      <xsl:with-param name="shift" select="$barShift" />
    </xsl:call-template>

    <xsl:call-template name="fiveteen-day-line-mark" >
      <xsl:with-param name="shift" select="($barShift + 15)" />
    </xsl:call-template>
  </xsl:template>

  <!-- ...... Current Date Mark ........ -->
  <xsl:template name="current-date-mark" >
    <!--    <svg:rect 	width="8"
	 height="8"
	 x="{$current-date-days * $dayFactor}" 
	 y="89"-->
    <svg:path d="M {($current-date-days * $dayFactor) + $left-side-panel} 87 l 8 12 l -16 0 Z"

style="opacity:0.744;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1.60000002;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
id="date"
/>
  </xsl:template>

    <!-- ...... Advance average ........ -->
  <xsl:template name="main-average" >

    <xsl:variable
	name="full-advance"
	select="sum(//task/timming/oficial)" />

    <xsl:variable
	name="estimated-advance"
	select="floor(
		sum(//task/timming[advance/text() and advance/text() != '0']/( oficial * ( advance div 100 ))

)
)" />
    <xsl:comment> Scope total : <xsl:value-of
    select="$full-advance" /> - Advance total <xsl:value-of
    select="$estimated-advance" /> -
    </xsl:comment>

    <svg:circle
	cx="70" cy="35" r="30"
  	stroke="#aaaabb" style="fill-opacity:0;stroke:solid;stroke-width:10px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1; "
	/>
      <svg:text
	  xml:space="preserve"
	  style="font-style:normal;font-weight:bold;font-size:20px;line-height:100%;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#8888aa;fill-opacity:0.6;stroke:solid;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;"
	  x="30" 
	  y="40"
	  id="main-advance"
	  >	

	<xsl:value-of
	    select=" concat( floor( ($estimated-advance div ($full-advance+1)) * 100), '%')   " />
      </svg:text>    
    
    
  </xsl:template>
  
</xsl:stylesheet>
