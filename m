From: "Lisong Xu" <lxu2@unity.ncsu.edu>
Subject: Intel PRO/1000 NIC
Date: Mon, 15 Sep 2003 10:35:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <00ff01c37b96$9ddb4650$8c330e98@nanegrc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I am sending UDP data from one PC to another PC directly through a cross
cable. The NIC of sender is Intel=AE PRO/1000 MT Server Adapter, and the =
NIC
of receiver is on-board Intel PRO/1000 (Dell PowerEdge 1600SC).

After tuning the kernel and driver parameters, the sender can send data a=
t
1Gbps. But the receiver can only receive data at 620Mbps. (see the follow=
ing
ifconfig messages, 30 seconds test)

*********** Sender *******************
eth1      Link encap:Ethernet  HWaddr 00:07:E9:17:84:36
          inet addr:192.168.1.100  Bcast:192.168.1.255  Mask:255.255.255.=
0
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
          RX packets:111 errors:0 dropped:0 overruns:0 frame:0
          TX packets:418072 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:30000
          RX bytes:26193 (25.5 Kb)  TX bytes:3759596626 (3585.4 Mb)
          Interrupt:24 Base address:0xccc0 Memory:fcd00000-fcd20000
**************Receiver***********************
eth0      Link encap:Ethernet  HWaddr 00:C0:9F:1E:3A:46
          inet addr:192.168.1.101  Bcast:192.168.1.255  Mask:255.255.255.=
0
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
          RX packets:261355 errors:156688 dropped:156688 overruns:156688
frame:0   <---- Look here!!!!!
          TX packets:97 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:30000
          RX bytes:2350019728 (2241.1 Mb)  TX bytes:22821 (22.2 Kb)
          Interrupt:11 Base address:0xecc0 Memory:fe100000-fe120000
***************************************************

My questions is why so many packets are "errors, dropped, overruns". I ha=
ve
adjusted the "TxDescriptors, RxDescriptors, RxIntDelay,
RxAbsIntDelay, TxIntDelay, TxAbsIntDelay" for different values, but alway=
s
got similar result.

Maybe here is not the right email list to send, but I am really frustrate=
d
with this problems, and hope to get some suggestions from the experts
here.Any suggestion is really appreciated!

Lisong
