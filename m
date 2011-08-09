From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RSS mode performance in ixgbe (82599) driver
Date: Tue, 09 Aug 2011 14:43:28 +0200
Message-ID: <1312893808.2371.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E41222B.8060003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "J.Hwan Kim" <frog1120@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E41222B.8060003@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 09 ao=C3=BBt 2011 =C3=A0 21:03 +0900, J.Hwan Kim a =C3=A9crit =
:
> Hi, everyone
>=20
> I'm testing the RSS mode throughput of Intel ixgbe 82599 driver.
> My server's specification is Xeon 3GHz (4cores) and PCIe speed is=20
> 2.5Gx8lanes,
> and DD2 memory is about 600~700MHz.
>=20
> When I enable the RSS(receive side scaling) mode with 4 Rx queues,
> the Rx performance is below than when I use a single queue.
>=20
> I don't know how the cores operate, whether the cores run in sequence
> or simultaneously at the same time.
>=20
> I want to know the mechanism in general how the multi-cores run
> and the reason why the performance of ixgbe driver in rss mode is bel=
ow
> non-rss mode.

CC netdev, as these kind of stuff is better hosted on netdev

You should make sure your 4 rx queues are serviced by different cpus, o=
r
else, one cpu could be the bottleneck.

cat /proc/interrupts
