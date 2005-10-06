From: =?iso-8859-1?Q?Fr=E9d=E9ric_POTTER?= <fpotter@cirpack.com>
Subject: 440bx and natsemi
Date: Thu, 6 Oct 2005 09:01:18 +0200
Message-ID: <8F5DB51133D6B84383761A7F0E399A7EBEA99D@epicure.suresnes.local>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5CA43.C0188EE3"
Cc: "Manfred Spraul" <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C5CA43.C0188EE3
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

=20
    Hi,=20
=20
    We have designed an embedded board, based on Celeron ULV 400 Mhz and =
440bx chipset.
    The BIOS has been derivated from Linux Bios of the 440mx (mx and bx =
have minimal differences).
    The ethernet devices are natsemi DP83816 (latest HW revision)
=20
The issue :=20
----------------
=20
    If we set the L1 CPU cache in write back mode then, under heavy =
ethernet load, we have various memory
corruption on the host memory. It looks like, basically, the natsemi =
device, when getting bus master, is=20
accessing former skbuf physicall adresses in the tx_ring structure, and =
therefore writing at various location
in the memory, generating various kernel panic a few moment later.
=20
    If we set the L1 CPU cache in write through, the issue vanishes =
completely (even after a few days of heavy
load)..
=20
    Since we have designed this whole system (hardware, BIOS etc..), it =
may clearly be that we have introduced
a cache coherency issue in the system, but we have checked it all, and =
it seems like not
    * snooping HW interface is present, correctly wired
    * Intel CPU and chipset seems to be properly configured, and anyway =
no configuration seems to be present
that would have allowed us to 'disable' cache coherency.
    * No Intel CPU or chipset errata have been found that refers to =
cache snooping issues.
=20
Does anyone have a clue on this one ? Does someone have a 440bx with a =
Natsemi device (that may be a rare
configuration BTW, since 440bx is used in laptop where the natsemi is =
fairly rare)=20
Are we just discovering an N+1 Intel issue or did we miss something ?
=20
thanks in advance
=20
fred

------_=_NextPart_001_01C5CA43.C0188EE3
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Message</TITLE>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2900.2722" name=3DGENERATOR></HEAD>
<BODY>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial =
size=3D2>&nbsp;&nbsp;&nbsp;=20
Hi, </FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial=20
size=3D2>We have designed an embedded board, based on Celeron ULV 400 =
Mhz and=20
440bx chipset.</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial=20
size=3D2>The BIOS has been derivated from Linux Bios of the 440mx (mx =
and bx have=20
minimal differences).</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial=20
size=3D2>The ethernet devices are natsemi DP83816 (latest HW=20
revision)</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial size=3D2>The =
issue :=20
</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2>----------------</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial=20
size=3D2>If we set the L1 CPU&nbsp;cache in write back mode then, under =
heavy=20
ethernet load, we have various memory</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial =
size=3D2>corruption on the=20
host memory. It looks like, basically, the natsemi device, when getting =
bus=20
master,&nbsp;is </FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial =
size=3D2>accessing former=20
skbuf </FONT></SPAN><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2>physicall adresses in the tx_ring structure, and therefore =
writing at=20
various location</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial size=3D2>in the =
memory,=20
generating various kernel panic a few moment later.</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial=20
size=3D2>If we set the L1 CPU cache in write through, the issue vanishes =

completely (even after a few days of heavy</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2>load)..</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial=20
size=3D2>Since we have designed this whole system (hardware, BIOS =
etc..), it may=20
clearly be that we have introduced</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial size=3D2>a =
cache coherency=20
issue in the system, but we have checked it all, and it seems like=20
not</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial size=3D2>*=20
snooping HW interface is present, correctly wired</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial size=3D2>*=20
Intel CPU and chipset seems to be properly configured, and anyway no=20
configuration seems to be present</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial size=3D2>that =
would have=20
allowed us to 'disable' cache coherency.</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005>&nbsp;&nbsp;&nbsp; <FONT =
face=3DArial size=3D2>*=20
No Intel CPU or chipset errata have been found that refers to cache =
snooping=20
issues.</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial size=3D2>Does =
anyone have a=20
clue on this one ? Does someone have a 440bx with a Natsemi device (that =
may be=20
a rare</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial =
size=3D2>configuration BTW,=20
since 440bx is used in laptop where the natsemi is fairly rare)=20
</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial size=3D2>Are we =
just=20
discovering an N+1 Intel issue or did we miss something =
?</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial size=3D2>thanks =
in=20
advance</FONT></SPAN></DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D679364606-06102005><FONT face=3DArial=20
size=3D2>fred</FONT></SPAN></DIV></BODY></HTML>

------_=_NextPart_001_01C5CA43.C0188EE3--
