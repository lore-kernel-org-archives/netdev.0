From: Yan-Fa Li <yan@intruvert.com>
Subject: RE: RFC: per-socket statistics on received/dropped packets
Date: Wed, 12 Jun 2002 13:30:32 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <D71BEAC27500D51199DF0002B328BA8D4FBC4D@ivexs1.intruvert.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C21250.003397A0"
Cc: Mark Mielke <mark@mark.mielke.cc>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "'Ben Greear'" <greearb@candelatech.com>,
   Pekka Savola
	 <pekkas@netcore.fi>
List-Id: netdev.vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C21250.003397A0
Content-Type: text/plain

Does this do what is needed ?  I've used it and it does have an impact on
stack performance while the application is running, but it tells you about
retransmits and what not, and does not seem to affect  performance much
until you actually want to inspect the values.  I agree with DaveM that it
should not go into the mainline kernel unless you can turn it off with a
sysctl, but it is useful for debugging and network health monitoring.

Y

http://heron.ucsd.edu/tcphealth/


------_=_NextPart_001_01C21250.003397A0
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2653.12">
<TITLE>RE: RFC: per-socket statistics on received/dropped =
packets</TITLE>
</HEAD>
<BODY>

<P><FONT SIZE=3D2>Does this do what is needed ?&nbsp; I've used it and =
it does have an impact on stack performance while the application is =
running, but it tells you about retransmits and what not, and does not =
seem to affect&nbsp; performance much until you actually want to =
inspect the values.&nbsp; I agree with DaveM that it should not go into =
the mainline kernel unless you can turn it off with a sysctl, but it is =
useful for debugging and network health monitoring.</FONT></P>

<P><FONT SIZE=3D2>Y</FONT>
</P>

<P><FONT SIZE=3D2><A HREF=3D"http://heron.ucsd.edu/tcphealth/" =
TARGET=3D"_blank">http://heron.ucsd.edu/tcphealth/</A></FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C21250.003397A0--
