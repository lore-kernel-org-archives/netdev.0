From: "Prashant Batra (prbatra)" <prbatra-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: ipsec tunnel with different inner and outer ip
	families
Date: Fri, 13 Jan 2012 12:41:38 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2058AF974@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2155606533388579848=="
To: <ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
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

--===============2155606533388579848==
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CCD1C2.9B1BA06C"
Content-class: urn:content-classes:message

This is a multi-part message in MIME format.

------_=_NextPart_001_01CCD1C2.9B1BA06C
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello,

=20

Does linux 2.6.* support an IPSec tunnel with different family of inner
and outer addresses , like v4 in v6 or v6 in v4.

After trying ip xfrm * from user space, the utility doesn't seem to
accept two different families in a single command.

=20

#ip xfrm policy add dir out src 172.168.68.1/32 dst 172.168.68.2/32 tmpl
src 2001:db8:0:242::36/128 dst 2001:db8:0:242::37/128 proto esp  mode
tunnel

Error: an inet prefix is expected rather than "2001:db8:0:242::36/128".

=20

So, I tried sending a NETLINK SPD add message) from user space with,
selector as v4 addresses and tmpl as v6 address.

Policy got added but kernel doesn't seem to be interpreting the
addresses correctly.

=20

src 172.16.80.1/32 dst 0.0.0.0/0

        dir out priority 1024

        tmpl    src 32.1.13.184 dst 32.1.13.184   /* I gave ipv6
addresses here*/

                proto esp spi 0x00000000 reqid 0 mode tunnel

=20

Can someone help me with this?

=20

Regards,

Prashant.


------_=_NextPart_001_01CCD1C2.9B1BA06C
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

<p class=3DMsoNormal>Hello,<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>Does linux 2.6.* support an IPSec tunnel with =
different
family of inner and outer addresses , like v4 in v6 or v6 in =
v4.<o:p></o:p></p>

<p class=3DMsoNormal>After trying ip xfrm * from user space, the utility =
doesn&#8217;t
seem to accept two different families in a single =
command.<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>#ip xfrm policy add dir out src 172.168.68.1/32 dst
172.168.68.2/32 tmpl src 2001:db8:0:242::36/128 dst =
2001:db8:0:242::37/128
proto esp&nbsp; mode tunnel<o:p></o:p></p>

<p class=3DMsoNormal>Error: an inet prefix is expected rather than
&quot;2001:db8:0:242::36/128&quot;.<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>So, I tried sending a NETLINK SPD add message) from =
user
space with, selector as v4 addresses and tmpl as v6 =
address.<o:p></o:p></p>

<p class=3DMsoNormal>Policy got added but kernel doesn&#8217;t seem to =
be interpreting
the addresses correctly.<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>src 172.16.80.1/32 dst 0.0.0.0/0<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dir out =
priority
1024<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tmpl&nbsp;&nbsp;&nbsp; src 32.1.13.184 dst 32.1.13.184&nbsp;&nbsp; /* I =
gave
ipv6 addresses here*/<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
proto esp spi 0x00000000 reqid 0 mode tunnel<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>Can someone help me with this?<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>Regards,<o:p></o:p></p>

<p class=3DMsoNormal>Prashant.<o:p></o:p></p>

</div>

</body>

</html>

------_=_NextPart_001_01CCD1C2.9B1BA06C--


--===============2155606533388579848==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
RSA(R) Conference 2012
Mar 27 - Feb 2
Save $400 by Jan. 27
Register now!
http://p.sf.net/sfu/rsa-sfdev2dev2
--===============2155606533388579848==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2155606533388579848==--
