From: "Nitin Yadav" <Nitin.Yadav@mphasis.com>
Subject: Linux Kernel  not responding to ARP requests
Date: Thu, 27 Sep 2012 12:21:01 +0530
Message-ID: <E351E450E8B9F54684A699D42DC5ADF225742BC8@MPBAGVEX02.corp.mphasis.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5417002951118473381=="
To: <linux-kernel@vger.kernel.org>, <kernelnewbies@kernelnewbies.org>,
	<netdev@vger.kernel.org>
Return-path: <kernelnewbies-bounces@kernelnewbies.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies>,
	<mailto:kernelnewbies-request@kernelnewbies.org?subject=unsubscribe>
List-Archive: <http://lists.kernelnewbies.org/pipermail/kernelnewbies>
List-Post: <mailto:kernelnewbies@kernelnewbies.org>
List-Help: <mailto:kernelnewbies-request@kernelnewbies.org?subject=help>
List-Subscribe: <http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies>,
	<mailto:kernelnewbies-request@kernelnewbies.org?subject=subscribe>
Sender: kernelnewbies-bounces@kernelnewbies.org
Errors-To: kernelnewbies-bounces@kernelnewbies.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============5417002951118473381==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CD9C7D.01558FC0"

This is a multi-part message in MIME format.

------_=_NextPart_001_01CD9C7D.01558FC0
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

 =


 =


From: Nitin Yadav =

Sent: Thursday, September 27, 2012 12:16 PM
To: 'netdev@vger.kernel.org'
Subject: RE: Linux Kernel not responding to ARP requests

 =


Hi All,

    I am facing loss of connectivity between Linux system (2.6.18
kernel) & Cisco switch (6509) when HSRP is enabled. The Cisco switches
(STAND BY) ARP queue were flushed and new MAC address were requests, but
the kernel did not answer to this requests. =


                After investigation I found out that the Cisco switch
(STAND BY) is flushing the MAC address of the kernel port. Based on
Cisco they are flush the MAC address of inactive port every 8 minutes. =


 =


A small note about the protocol (HSRP):-

Hot Standby Router Protocol (HSRP) is a Cisco proprietary redundancy
protocol for establishing a fault-tolerant default gateway, and has been
described in detail in RFC 2281.

The protocol establishes a framework between network routers in order to
achieve default gateway failover if the primary gateway becomes
inaccessible,[1] in close association with a rapid-converging routing
protocol like EIGRP or OSPF. By multicasting packets, HSRP sends its
hello messages to the multicast address 224.0.0.2 (all routers) for
version 1, or 224.0.0.102 for version 2[2], using UDP port 1985, to
other HSRP-enabled routers, defining priority between the routers. The
primary router with the highest configured priority will act as a
virtual router with a pre-defined gateway IP address and will respond to
the ARP request from machines connected to the LAN with the MAC address
0000.0c07.acXX where XX is the group ID in hex. If the primary router
should fail, the router with the next-highest priority would take over
the gateway IP address and answer ARP requests with the same mac
address, thus achieving transparent default gateway fail-over. A HSRP
Basics Simulation visualizes Active/Standby election and link failover
with Hello, Coup, ARP Reply packets and timers.

 =


My queries :-

Is there any way Kernel is dropping the ARP requests (from the Stand by
Router to the Kernel)? =


If it's not dropping, is there any other reason for not replying to ARP?

 =


Thanks!

Nitin Yadav

 =



Information transmitted by this e-mail is proprietary to MphasiS, its assoc=
iated companies and/ or its customers and is intended =

for use only by the individual or entity to which it is addressed, and may =
contain information that is privileged, confidential or =

exempt from disclosure under applicable law. If you are not the intended re=
cipient or it appears that this mail has been forwarded =

to you without proper authority, you are notified that any use or dissemina=
tion of this information in any manner is strictly =

prohibited. In such cases, please notify us immediately at mailmaster@mphas=
is.com and delete this mail from your records.

------_=_NextPart_001_01CD9C7D.01558FC0
MIME-Version: 1.0
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40"><head><META HTTP-EQUIV=3D"Content-Type" CONTENT=
=3D"text/html; charset=3Dus-ascii"><meta name=3DGenerator content=3D"Micros=
oft Word 12 (filtered medium)"><style><!--
/* Font Definitions */
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
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
p.xmsonormal, li.xmsonormal, div.xmsonormal
	{mso-style-name:x_msonormal;
	mso-margin-top-alt:auto;
	margin-right:0in;
	mso-margin-bottom-alt:auto;
	margin-left:0in;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";}
span.EmailStyle18
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
span.EmailStyle19
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
span.EmailStyle20
	{mso-style-type:personal-reply;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]--></head><body lang=3DEN-US link=3Dblue vli=
nk=3Dpurple><div class=3DWordSection1><p class=3DMsoNormal><span style=3D'c=
olor:#1F497D'><o:p>&nbsp;</o:p></span></p><p class=3DMsoNormal><span style=
=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p><div><div style=3D'border:no=
ne;border-top:solid #B5C4DF 1.0pt;padding:3.0pt 0in 0in 0in'><p class=3DMso=
Normal><b><span style=3D'font-size:10.0pt;font-family:"Tahoma","sans-serif"=
'>From:</span></b><span style=3D'font-size:10.0pt;font-family:"Tahoma","san=
s-serif"'> Nitin Yadav <br><b>Sent:</b> Thursday, September 27, 2012 12:16 =
PM<br><b>To:</b> 'netdev@vger.kernel.org'<br><b>Subject:</b> RE: Linux Kern=
el not responding to ARP requests<o:p></o:p></span></p></div></div><p class=
=3DMsoNormal><o:p>&nbsp;</o:p></p><p class=3DMsoNormal>Hi All,<o:p></o:p></=
p><p class=3DMsoNormal>&nbsp;&nbsp;&nbsp; I am facing loss of connectivity =
between Linux system (2.6.18 kernel) &amp; Cisco switch (6509) when HSRP is=
 enabled. The Cisco switches (STAND BY) ARP queue were flushed and new MAC =
address were requests, but the kernel did not answer to this requests. <o:p=
></o:p></p><p class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; After investigation I found=
 out that the Cisco switch (STAND BY) is flushing the MAC address of the ke=
rnel port. Based on Cisco they are flush the MAC address of inactive port e=
very 8 minutes. <o:p></o:p></p><p class=3DMsoNormal><o:p>&nbsp;</o:p></p><p=
 class=3DMsoNormal><i>A small note about the protocol (HSRP):-<o:p></o:p></=
i></p><p class=3DMsoNormal><i>Hot Standby Router Protocol (HSRP) is a Cisco=
 proprietary redundancy protocol for establishing a fault-tolerant default =
gateway, and has been described in detail in RFC 2281.<o:p></o:p></i></p><p=
 class=3DMsoNormal><i>The protocol establishes a framework between network =
routers in order to achieve default gateway failover if the primary gateway=
 becomes inaccessible,[1] in close association with a rapid-converging rout=
ing protocol like EIGRP or OSPF. By multicasting packets, HSRP sends its he=
llo messages to the multicast address 224.0.0.2 (all routers) for version 1=
, or 224.0.0.102 for version 2[2], using UDP port 1985, to other HSRP-enabl=
ed routers, defining priority between the routers. The primary router with =
the highest configured priority will act as a virtual router with a pre-def=
ined gateway IP address and will respond to the ARP request from machines c=
onnected to the LAN with the MAC address 0000.0c07.acXX where XX is the gro=
up ID in hex. If the primary router should fail, the router with the next-h=
ighest priority would take over the gateway IP address and answer ARP reque=
sts with the same mac address, thus achieving transparent default gateway f=
ail-over. A HSRP Basics Simulation visualizes Active/Standby election and l=
ink failover with Hello, Coup, ARP Reply packets and timers.<o:p></o:p></i>=
</p><p class=3DMsoNormal><o:p>&nbsp;</o:p></p><p class=3DMsoNormal>My queri=
es :&#8211;<o:p></o:p></p><p class=3DMsoNormal>Is there any way Kernel is d=
ropping the ARP requests (from the Stand by Router to the Kernel)? <o:p></o=
:p></p><p class=3DMsoNormal>If it&#8217;s not dropping, is there any other =
reason for not replying to ARP?<o:p></o:p></p><p class=3DMsoNormal><o:p>&nb=
sp;</o:p></p><p class=3DMsoNormal>Thanks!<o:p></o:p></p><p class=3DMsoNorma=
l>Nitin Yadav<o:p></o:p></p><p class=3DMsoNormal><o:p>&nbsp;</o:p></p></div=
><p><br>
Information transmitted by this e-mail is proprietary to MphasiS, its assoc=
iated companies and/ or its customers and is intended <br>
for use only by the individual or entity to which it is addressed, and may =
contain information that is privileged, confidential or <br>
exempt from disclosure under applicable law. If you are not the intended re=
cipient or it appears that this mail has been forwarded <br>
to you without proper authority, you are notified that any use or dissemina=
tion of this information in any manner is strictly <br>
prohibited. In such cases, please notify us immediately at mailmaster@mphas=
is.com and delete this mail from your records.</p></body></html>
------_=_NextPart_001_01CD9C7D.01558FC0--



--===============5417002951118473381==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernelnewbies mailing list
Kernelnewbies@kernelnewbies.org
http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies

--===============5417002951118473381==--
