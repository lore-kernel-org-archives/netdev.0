From: "Simon Barber" <simon@devicescape.com>
Subject: Why is packet socket checked before bridge in netif_receive_skb?
Date: Tue, 26 Jul 2005 11:03:17 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F6AF010@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C5920C.4C252365"
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C5920C.4C252365
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

In netif_receive_skb there is code that checks the ptype_all handlers
(protocol handlers that want to handle all protocol types) before the
bridge hook, and code to check the specific protocol handlers after the
bridge hook.
=20
The protocol handlers are also used to implement packet sockets. - Why
is the all handler checked before the bridge hook?
=20
(I'm reading code from 2.4.26).
=20
Simon
=20

------_=_NextPart_001_01C5920C.4C252365
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.2604" name=3DGENERATOR></HEAD>
<BODY>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D915455717-26072005>In =
netif_receive_skb=20
there is code that checks the ptype_all handlers (protocol handlers that =
want to=20
handle all protocol types) before the bridge hook, and code to check the =

specific protocol handlers after the bridge hook.</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D915455717-26072005></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D915455717-26072005>The =
protocol=20
handlers are also used to implement packet sockets. - Why is the all =
handler=20
checked before the bridge hook?</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D915455717-26072005></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D915455717-26072005>(I'm =
reading code=20
from 2.4.26).</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D915455717-26072005></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D915455717-26072005>Simon</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D915455717-26072005></SPAN></FONT>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C5920C.4C252365--
