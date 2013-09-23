From: Dani Camps <danicamps81@yahoo.com>
Subject: Problem with tap interface: link is not ready
Date: Mon, 23 Sep 2013 16:51:47 +0100 (BST)
Message-ID: <1379951507.84403.YahooMailNeo@web172101.mail.ir2.yahoo.com>
Reply-To: Dani Camps <danicamps81@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm22-vm8.bullet.mail.ird.yahoo.com ([212.82.109.227]:46626 "EHLO
	nm22-vm8.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613Ab3IWP61 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 11:58:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dear all,

I am not sure that I am addressing the correct mailing list. In case I =
am not, please accept my apologies.

I am trying to create a virtual tap device that I want to add later on =
to a bridge. My problem is that the tap interface always appears with s=
tate disabled if I do a =B4brctl showstp br0=B4, and no traffic reaches=
 the bridge.=A0After some investigation I found out that the tap interf=
ace is never up. How can I bring the tap interface up?

These are my detailed steps:

sudo tunctl -t tap0
sudo ifconfig tap0 192.168.0.2/24 up

But when I look at dmesg I get:

=A0ADDRCONF(NETDEV_UP): tap0: link is not ready


Nevertheless if I do 'ifconfig tap0' it seems to indicate that the inte=
rface is up:

tap0 =A0 =A0 =A0Link encap:Ethernet =A0HWaddr 72:a0:fb:88:95:44
=A0 =A0 =A0 =A0 =A0 inet addr:192.168.0.2 =A0Bcast:192.168.0.255 =A0Mas=
k:255.255.255.0
=A0 =A0 =A0 =A0 =A0 UP BROADCAST MULTICAST =A0MTU:1500 =A0Metric:1
=A0 =A0 =A0 =A0 =A0 RX packets:0 errors:0 dropped:0 overruns:0 frame:0
=A0 =A0 =A0 =A0 =A0 TX packets:0 errors:0 dropped:0 overruns:0 carrier:=
0
=A0 =A0 =A0 =A0 =A0 collisions:0 txqueuelen:500
=A0 =A0 =A0 =A0 =A0 RX bytes:0 (0.0 B) =A0TX bytes:0 (0.0 B)

But I never see a message in dmesg saying "tap0: link becomes ready." A=
nd when I add the tap0 interface it always appears disabled, so I think=
 that the interface is never really up.

My kernel is 3.0

Any help to bring up the tap interface is much appreciated.

Best Regards

Daniel
