From: "Lisong Xu" <lxu2@unity.ncsu.edu>
Subject: Re: Intel PRO/1000 NIC
Date: Fri, 19 Sep 2003 16:26:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <00cb01c37eec$5e27e3c0$8c330e98@nanegrc>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_00C8_01C37ECA.D6C0A9B0"
Return-path: <netdev-bounce@oss.sgi.com>
To: "Lisong Xu" <lxu2@unity.ncsu.edu>, <netdev@oss.sgi.com>,
        <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_00C8_01C37ECA.D6C0A9B0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello,

Just in case you have a similar problem.=20

The possible reason is that the on-board Inter 1000 chip of Dell =
PowerEdge 1600SC is Intel 82540EM, which is running PCI 32/33 or PCI =
32/66.

Lisong

----- Original Message -----=20
  From: Lisong Xu=20
  To: netdev@oss.sgi.com ; linux-kernel@vger.kernel.org=20
  Sent: Monday, September 15, 2003 10:35 AM
  Subject: Intel PRO/1000 NIC


  Hello,

  I am sending UDP data from one PC to another PC directly through a =
cross
  cable. The NIC of sender is Intel=AE PRO/1000 MT Server Adapter, and =
the NIC
  of receiver is on-board Intel PRO/1000 (Dell PowerEdge 1600SC).

  After tuning the kernel and driver parameters, the sender can send =
data at
  1Gbps. But the receiver can only receive data at 620Mbps. (see the =
following
  ifconfig messages, 30 seconds test)

  *********** Sender *******************
  eth1      Link encap:Ethernet  HWaddr 00:07:E9:17:84:36
            inet addr:192.168.1.100  Bcast:192.168.1.255  =
Mask:255.255.255.0
            UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
            RX packets:111 errors:0 dropped:0 overruns:0 frame:0
            TX packets:418072 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:30000
            RX bytes:26193 (25.5 Kb)  TX bytes:3759596626 (3585.4 Mb)
            Interrupt:24 Base address:0xccc0 Memory:fcd00000-fcd20000
  **************Receiver***********************
  eth0      Link encap:Ethernet  HWaddr 00:C0:9F:1E:3A:46
            inet addr:192.168.1.101  Bcast:192.168.1.255  =
Mask:255.255.255.0
            UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
            RX packets:261355 errors:156688 dropped:156688 =
overruns:156688
  frame:0   <---- Look here!!!!!
            TX packets:97 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:30000
            RX bytes:2350019728 (2241.1 Mb)  TX bytes:22821 (22.2 Kb)
            Interrupt:11 Base address:0xecc0 Memory:fe100000-fe120000
  ***************************************************

  My questions is why so many packets are "errors, dropped, overruns". I =
have
  adjusted the "TxDescriptors, RxDescriptors, RxIntDelay,
  RxAbsIntDelay, TxIntDelay, TxAbsIntDelay" for different values, but =
always
  got similar result.

  Maybe here is not the right email list to send, but I am really =
frustrated
  with this problems, and hope to get some suggestions from the experts
  here.Any suggestion is really appreciated!

  Lisong





------=_NextPart_000_00C8_01C37ECA.D6C0A9B0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1226" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hello,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Just in case you have a similar =
problem.=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>The possible reason is that the =
on-board Inter 1000=20
chip of Dell PowerEdge 1600SC is <FONT face=3D"Times New Roman" =
size=3D3>Intel=20
</FONT><FONT face=3D"Times New Roman" size=3D3>82540EM, which is running =
PCI 32/33=20
or PCI 32/66.</FONT></FONT></DIV>
<DIV>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Lisong</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV>----- Original Message ----- </DIV>
<BLOCKQUOTE=20
style=3D"PADDING-RIGHT: 0px; PADDING-LEFT: 5px; MARGIN-LEFT: 5px; =
BORDER-LEFT: #000000 2px solid; MARGIN-RIGHT: 0px">
  <DIV=20
  style=3D"BACKGROUND: #e4e4e4; FONT: 10pt arial; font-color: =
black"><B>From:</B>=20
  <A title=3Dlxu2@unity.ncsu.edu =
href=3D"mailto:lxu2@unity.ncsu.edu">Lisong Xu</A>=20
  </DIV>
  <DIV style=3D"FONT: 10pt arial"><B>To:</B> <A =
title=3Dnetdev@oss.sgi.com=20
  href=3D"mailto:netdev@oss.sgi.com">netdev@oss.sgi.com</A> ; <A=20
  title=3Dlinux-kernel@vger.kernel.org=20
  =
href=3D"mailto:linux-kernel@vger.kernel.org">linux-kernel@vger.kernel.org=
</A>=20
  </DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Sent:</B> Monday, September 15, =
2003 10:35=20
  AM</DIV>
  <DIV style=3D"FONT: 10pt arial"><B>Subject:</B> Intel PRO/1000 =
NIC</DIV>
  <DIV><BR></DIV>Hello,<BR><BR>I am sending UDP data from one PC to =
another PC=20
  directly through a cross<BR>cable. The NIC of sender is Intel=AE =
PRO/1000 MT=20
  Server Adapter, and the NIC<BR>of receiver is on-board Intel PRO/1000 =
(Dell=20
  PowerEdge 1600SC).<BR><BR>After tuning the kernel and driver =
parameters, the=20
  sender can send data at<BR>1Gbps. But the receiver can only receive =
data at=20
  620Mbps. (see the following<BR>ifconfig messages, 30 seconds=20
  test)<BR><BR>*********** Sender=20
  *******************<BR>eth1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Link=20
  encap:Ethernet&nbsp; HWaddr=20
  =
00:07:E9:17:84:36<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;=20
  inet addr:192.168.1.100&nbsp; Bcast:192.168.1.255&nbsp;=20
  =
Mask:255.255.255.0<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;=20
  UP BROADCAST RUNNING MULTICAST&nbsp; MTU:9000&nbsp;=20
  Metric:1<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; RX=20
  packets:111 errors:0 dropped:0 overruns:0=20
  frame:0<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TX=20
  packets:418072 errors:0 dropped:0 overruns:0=20
  carrier:0<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  collisions:0=20
  =
txqueuelen:30000<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; RX=20
  bytes:26193 (25.5 Kb)&nbsp; TX bytes:3759596626 (3585.4=20
  Mb)<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
Interrupt:24=20
  Base address:0xccc0=20
  =
Memory:fcd00000-fcd20000<BR>**************Receiver***********************=
<BR>eth0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  Link encap:Ethernet&nbsp; HWaddr=20
  =
00:C0:9F:1E:3A:46<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;=20
  inet addr:192.168.1.101&nbsp; Bcast:192.168.1.255&nbsp;=20
  =
Mask:255.255.255.0<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;=20
  UP BROADCAST RUNNING MULTICAST&nbsp; MTU:9000&nbsp;=20
  Metric:1<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; RX=20
  packets:261355 errors:156688 dropped:156688=20
  overruns:156688<BR>frame:0&nbsp;&nbsp; &lt;---- Look=20
  here!!!!!<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TX =

  packets:97 errors:0 dropped:0 overruns:0=20
  carrier:0<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
  collisions:0=20
  =
txqueuelen:30000<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; RX=20
  bytes:2350019728 (2241.1 Mb)&nbsp; TX bytes:22821 (22.2=20
  Kb)<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
Interrupt:11=20
  Base address:0xecc0=20
  =
Memory:fe100000-fe120000<BR>*********************************************=
******<BR><BR>My=20
  questions is why so many packets are "errors, dropped, overruns". I=20
  have<BR>adjusted the "TxDescriptors, RxDescriptors,=20
  RxIntDelay,<BR>RxAbsIntDelay, TxIntDelay, TxAbsIntDelay" for different =
values,=20
  but always<BR>got similar result.<BR><BR>Maybe here is not the right =
email=20
  list to send, but I am really frustrated<BR>with this problems, and =
hope to=20
  get some suggestions from the experts<BR>here.Any suggestion is really =

  =
appreciated!<BR><BR>Lisong<BR><BR><BR><BR><BR></BLOCKQUOTE></BODY></HTML>=


------=_NextPart_000_00C8_01C37ECA.D6C0A9B0--
