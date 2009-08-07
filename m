From: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Subject: Re: [evb] Re: [PATCH][RFC] net/bridge: add basic VEPA
	support
Date: Fri, 7 Aug 2009 12:44:06 -0700
Message-ID: <005101ca1797$70dcf5b0$5296e110$@edu>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net>
	<20090806210002.75beb7c6@nehalam>
	<200908071329.44437.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6106794152065959331=="
Cc: "'Fischer, Anna'" <anna.fischer@hp.com>, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        "'Or Gerlitz'" <ogerlitz@voltaire.com>, adobriyan@gmail.com,
        davem@davemloft.net
To: <evb@yahoogroups.com>,
        "'Stephen Hemminger'" <shemminger@linux-foundation.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <200908071329.44437.arnd@arndb.de>
Content-Language: en-us
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.

--===============6106794152065959331==
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0052_01CA175C.C47E1DB0"
Content-Language: en-us

This is a multipart message in MIME format.

------=_NextPart_000_0052_01CA175C.C47E1DB0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Arnd,

 

I don't think your scheme works too well because broadcast packet coming
from other interfaces on br0 would get replicated and sent across the wire
to ethB multiple times.

 

Paul

That way you should be able to do something
like:

Host A Host B

/- nalvcam0 -\ /- macvlan0 - 192.168.1.1
br0 -| |- ethA === ethB -|
\- nalvcam1 -/ \- macvlan1 - 192.168.1.2

Now assuming that macvlan0 and macvlan1 are in different
network namespaces or belong to different KVM guests, these
guests would be able to communicate with each other through
the bridge on host A, which can set the policy (using ebtables)
for this communication and get interface statistics on its
nalvcam interfaces. Also, instead of having the br0, Host A could
assign an IP addresses to the two nalvcam interfaces that host
B has, and use IP forwarding between the guests of host B.



 


------=_NextPart_000_0052_01CA175C.C47E1DB0
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:x=3D"urn:schemas-microsoft-com:office:excel" =
xmlns:p=3D"urn:schemas-microsoft-com:office:powerpoint" =
xmlns:a=3D"urn:schemas-microsoft-com:office:access" =
xmlns:dt=3D"uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" =
xmlns:s=3D"uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" =
xmlns:rs=3D"urn:schemas-microsoft-com:rowset" xmlns:z=3D"#RowsetSchema" =
xmlns:b=3D"urn:schemas-microsoft-com:office:publisher" =
xmlns:ss=3D"urn:schemas-microsoft-com:office:spreadsheet" =
xmlns:c=3D"urn:schemas-microsoft-com:office:component:spreadsheet" =
xmlns:odc=3D"urn:schemas-microsoft-com:office:odc" =
xmlns:oa=3D"urn:schemas-microsoft-com:office:activation" =
xmlns:html=3D"http://www.w3.org/TR/REC-html40" =
xmlns:q=3D"http://schemas.xmlsoap.org/soap/envelope/" =
xmlns:rtc=3D"http://microsoft.com/officenet/conferencing" =
xmlns:D=3D"DAV:" xmlns:Repl=3D"http://schemas.microsoft.com/repl/" =
xmlns:mt=3D"http://schemas.microsoft.com/sharepoint/soap/meetings/" =
xmlns:x2=3D"http://schemas.microsoft.com/office/excel/2003/xml" =
xmlns:ppda=3D"http://www.passport.com/NameSpace.xsd" =
xmlns:ois=3D"http://schemas.microsoft.com/sharepoint/soap/ois/" =
xmlns:dir=3D"http://schemas.microsoft.com/sharepoint/soap/directory/" =
xmlns:ds=3D"http://www.w3.org/2000/09/xmldsig#" =
xmlns:dsp=3D"http://schemas.microsoft.com/sharepoint/dsp" =
xmlns:udc=3D"http://schemas.microsoft.com/data/udc" =
xmlns:xsd=3D"http://www.w3.org/2001/XMLSchema" =
xmlns:sub=3D"http://schemas.microsoft.com/sharepoint/soap/2002/1/alerts/"=
 xmlns:ec=3D"http://www.w3.org/2001/04/xmlenc#" =
xmlns:sp=3D"http://schemas.microsoft.com/sharepoint/" =
xmlns:sps=3D"http://schemas.microsoft.com/sharepoint/soap/" =
xmlns:xsi=3D"http://www.w3.org/2001/XMLSchema-instance" =
xmlns:udcs=3D"http://schemas.microsoft.com/data/udc/soap" =
xmlns:udcxf=3D"http://schemas.microsoft.com/data/udc/xmlfile" =
xmlns:udcp2p=3D"http://schemas.microsoft.com/data/udc/parttopart" =
xmlns:wf=3D"http://schemas.microsoft.com/sharepoint/soap/workflow/" =
xmlns:dsss=3D"http://schemas.microsoft.com/office/2006/digsig-setup" =
xmlns:dssi=3D"http://schemas.microsoft.com/office/2006/digsig" =
xmlns:mdssi=3D"http://schemas.openxmlformats.org/package/2006/digital-sig=
nature" =
xmlns:mver=3D"http://schemas.openxmlformats.org/markup-compatibility/2006=
" xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" =
xmlns:mrels=3D"http://schemas.openxmlformats.org/package/2006/relationshi=
ps" xmlns:spwp=3D"http://microsoft.com/sharepoint/webpartpages" =
xmlns:ex12t=3D"http://schemas.microsoft.com/exchange/services/2006/types"=
 =
xmlns:ex12m=3D"http://schemas.microsoft.com/exchange/services/2006/messag=
es" =
xmlns:pptsl=3D"http://schemas.microsoft.com/sharepoint/soap/SlideLibrary/=
" =
xmlns:spsl=3D"http://microsoft.com/webservices/SharePointPortalServer/Pub=
lishedLinksService" xmlns:Z=3D"urn:schemas-microsoft-com:" =
xmlns:st=3D"&#1;" xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 12 (filtered medium)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Consolas;
	panose-1:2 11 6 9 2 2 4 3 2 4;}
@font-face
	{font-family:Verdana;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
p
	{mso-style-priority:99;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
code
	{mso-style-priority:99;
	font-family:"Courier New";}
pre
	{mso-style-priority:99;
	mso-style-link:"HTML Preformatted Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Courier New";}
tt
	{mso-style-priority:99;
	font-family:"Courier New";}
span.left
	{mso-style-name:left;}
span.bld
	{mso-style-name:bld;}
p.ad, li.ad, div.ad
	{mso-style-name:ad;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad1, li.ad1, div.ad1
	{mso-style-name:ad1;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad2, li.ad2, div.ad2
	{mso-style-name:ad2;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad3, li.ad3, div.ad3
	{mso-style-name:ad3;
	mso-margin-top-alt:auto;
	margin-right:0in;
	margin-bottom:7.5pt;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
span.HTMLPreformattedChar
	{mso-style-name:"HTML Preformatted Char";
	mso-style-priority:99;
	mso-style-link:"HTML Preformatted";
	font-family:Consolas;}
p.replbq, li.replbq, div.replbq
	{mso-style-name:replbq;
	margin:3.0pt;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
span.yshortcuts
	{mso-style-name:yshortcuts;}
p.ad4, li.ad4, div.ad4
	{mso-style-name:ad4;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad5, li.ad5, div.ad5
	{mso-style-name:ad5;
	mso-margin-top-alt:auto;
	margin-right:0in;
	margin-bottom:7.5pt;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
p.ad6, li.ad6, div.ad6
	{mso-style-name:ad6;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
span.yshortcuts1
	{mso-style-name:yshortcuts1;
	font-family:"Verdana","sans-serif";
	font-weight:bold;}
span.yshortcuts2
	{mso-style-name:yshortcuts2;
	font-family:"Verdana","sans-serif";
	font-weight:normal;}
span.EmailStyle35
	{mso-style-type:personal-reply;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:423189935;
	mso-list-template-ids:-1726194346;}
@list l0:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext=3D"edit">
  <o:idmap v:ext=3D"edit" data=3D"1" />
 </o:shapelayout></xml><![endif]-->
</head>

<body bgcolor=3Dwhite lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";
color:#1F497D'>Arnd,<o:p></o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";
color:#1F497D'><o:p>&nbsp;</o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";
color:#1F497D'>I don&#8217;t think your scheme works too well because =
broadcast
packet coming from other interfaces on br0 would get replicated and sent =
across
the wire to ethB multiple times.<o:p></o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";
color:#1F497D'><o:p>&nbsp;</o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'font-size:11.0pt;font-family:"Calibri","sans-serif";
color:#1F497D'>Paul<o:p></o:p></span></p>

<div style=3D'border:none;border-left:solid blue 1.5pt;padding:0in 0in =
0in 4.0pt'>

<div id=3Dygrp-mlmsg>

<div id=3Dygrp-msg>

<div id=3Dygrp-text>

<p style=3D'margin-left:5.25pt'>That way you should be able to do =
something<br>
like:<br>
<br>
Host A Host B<br>
<br>
/- nalvcam0 -\ /- macvlan0 - 192.168.1.1<br>
br0 -| |- ethA =3D=3D=3D ethB -|<br>
\- nalvcam1 -/ \- macvlan1 - 192.168.1.2<br>
<br>
Now assuming that macvlan0 and macvlan1 are in different<br>
network namespaces or belong to different KVM guests, these<br>
guests would be able to communicate with each other through<br>
the bridge on host A, which can set the policy (using ebtables)<br>
for this communication and get interface statistics on its<br>
nalvcam interfaces. Also, instead of having the br0, Host A could<br>
assign an IP addresses to the two nalvcam interfaces that host<br>
B has, and use IP forwarding between the guests of host B.<br>
<br>
<span style=3D'color:white'><o:p></o:p></span></p>

</div>

</div>

</div>

<div>

<p class=3DMsoNormal><span =
style=3D'color:white'><o:p>&nbsp;</o:p></span></p>

</div>

</div>

</div>

</body>

</html>

------=_NextPart_000_0052_01CA175C.C47E1DB0--


--===============6106794152065959331==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
--===============6106794152065959331==--
