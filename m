From: "Prashant Batra (prbatra)" <prbatra-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: IP forwarding
Date: Fri, 27 Jan 2012 15:29:48 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2059F2B31@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9000698790385968585=="
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipsec-tools-devel>
List-Post: <mailto:ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============9000698790385968585==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CCDCDA.6843C7FA"

This is a multi-part message in MIME format.

------_=_NextPart_001_01CCDCDA.6843C7FA
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

=20

I am trying to establish an IPSec tunnel to protect a subnet behind a
linux machine and a subnet behind some other gateway.

Lefsubnet - 172.17.0.0/16 (behind linux gateway)

Rightsubnet - 172.16.0.0/16

=20

>From a host on left subnet, I am trying to ping to a host on right
subnet-

ping 172.16.60.1 -I 172.17.70.87

=20

tcpdump capture on linux machine connected to left subnet-

04:27:09.939598 IP 172.17.70.87 > 172.16.60.1: icmp 64: echo request seq
170

=20

Tcpdump capture on linux machine connected on right subnet-

04:26:32.941624 IP 1.1.0.1 > 192.168.101.101:
ESP(spi=3D0x020000c3,seq=3D0x16d)                 //Outer IPs

04:26:32.943940 IP 192.168.101.101 > 1.1.0.1:
ESP(spi=3D0x10000102,seq=3D0x16d)

04:26:32.943940 IP 172.16.60.1 > 172.17.70.87: icmp 64: echo reply seq
133

=20

So, it's clear that linux gateway is able to protect the data and send
to the connected gateway (ESP packets to outer IPs).

And the second gateway is responding with ESP packet which is decoded on
linux gateway and sent to the ip stack again by linux kernel (ICMP
reply).

But the reply doesn't reach the host on left subnet.

=20

I enabled ip_forwarding through /proc/sys/net/ipv4/ip_forwarding.

=20

Please let me know, if I am missing something.

=20

Any help would be appreciated.

=20

Regards,

Prashant


------_=_NextPart_001_01CCDCDA.6843C7FA
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 12 (filtered medium)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext=3D"edit">
  <o:idmap v:ext=3D"edit" data=3D"1" />
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal>Hi,<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>I am trying to establish an IPSec tunnel to protect =
a subnet
behind a linux machine and a subnet behind some other =
gateway.<o:p></o:p></p>

<p class=3DMsoNormal>Lefsubnet &#8211; 172.17.0.0/16 (behind linux =
gateway)<o:p></o:p></p>

<p class=3DMsoNormal>Rightsubnet &#8211; 172.16.0.0/16<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>From a host on left subnet, I am trying to ping to =
a host on
right subnet-<o:p></o:p></p>

<p class=3DMsoNormal>ping 172.16.60.1 -I 172.17.70.87<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>tcpdump capture on linux machine connected to left =
subnet-<o:p></o:p></p>

<p class=3DMsoNormal>04:27:09.939598 IP 172.17.70.87 &gt; 172.16.60.1: =
icmp 64:
echo request seq 170<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>Tcpdump capture on linux machine connected on right =
subnet-<o:p></o:p></p>

<p class=3DMsoNormal>04:26:32.941624 IP 1.1.0.1 &gt; 192.168.101.101:
ESP(spi=3D0x020000c3,seq=3D0x16d)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
//Outer IPs<o:p></o:p></p>

<p class=3DMsoNormal>04:26:32.943940 IP 192.168.101.101 &gt; 1.1.0.1:
ESP(spi=3D0x10000102,seq=3D0x16d)<o:p></o:p></p>

<p class=3DMsoNormal>04:26:32.943940 IP 172.16.60.1 &gt; 172.17.70.87: =
icmp 64:
echo reply seq 133<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>So, it&#8217;s clear that linux gateway is able to =
protect
the data and send to the connected gateway (ESP packets to outer =
IPs).<o:p></o:p></p>

<p class=3DMsoNormal>And the second gateway is responding with ESP =
packet which
is decoded on linux gateway and sent to the ip stack again by linux =
kernel
(ICMP reply).<o:p></o:p></p>

<p class=3DMsoNormal>But the reply doesn&#8217;t reach the host on left =
subnet.<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>I enabled ip_forwarding through
/proc/sys/net/ipv4/ip_forwarding.<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>Please let me know, if I am missing =
something.<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>Any help would be appreciated.<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>Regards,<o:p></o:p></p>

<p class=3DMsoNormal>Prashant<o:p></o:p></p>

</div>

</body>

</html>

------_=_NextPart_001_01CCDCDA.6843C7FA--


--===============9000698790385968585==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Try before you buy = See our experts in action!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-dev2
--===============9000698790385968585==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============9000698790385968585==--
