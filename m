From: "Simon Barber" <simon@instant802.com>
Subject: Problem with ebtables target that changes frame protocol
Date: Mon, 23 Feb 2004 14:41:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <AC8C1F46CD753F4AAC8F890E35A9EB461C66EB@webmail.instant802.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C3FA5E.2870D9B8"
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Kernel Mailing List" <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3FA5E.2870D9B8
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I have written an ebtables target that changes the ethernet protocol of
a received frame (it runs in the broute chain). I have been working on
2.4.21 sources - Unfortunately inside netif_rx the skb->protocol is
looked at before the bridge code is called - and then acted upon after.
Hence if the bridge code changes the protocol the incorrect protocol is
used to process the frame.
=20
Simon

------_=_NextPart_001_01C3FA5E.2870D9B8
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<TITLE>Message</TITLE>

<META content=3D"MSHTML 6.00.2800.1400" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D095543722-23022004><FONT face=3DArial size=3D2>I have =
written an=20
ebtables target that changes the ethernet protocol of a received frame =
(it runs=20
in the broute chain). I have been working on 2.4.21 sources - =
Unfortunately=20
inside netif_rx the skb-&gt;protocol is looked at before the bridge code =
is=20
called - and then acted upon after. Hence if the bridge code changes the =

protocol the incorrect protocol is used to process the=20
frame.</FONT></SPAN></DIV>
<DIV><SPAN class=3D095543722-23022004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D095543722-23022004><FONT face=3DArial=20
size=3D2>Simon</FONT></SPAN></DIV></BODY></HTML>

------_=_NextPart_001_01C3FA5E.2870D9B8--
