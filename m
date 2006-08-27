From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-rc4-mm[1,2,3] -- Network card not getting assigned an
 "eth" device name
Date: Sun, 27 Aug 2006 00:19:43 -0700
Message-ID: <20060827001943.c559d37d.akpm@osdl.org>
References: <a44ae5cd0608270007gc6a919fx9e36562d8023635d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13783 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751315AbWH0HTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2006 03:19:49 -0400
To: "Miles Lane" <miles.lane@gmail.com>
In-Reply-To: <a44ae5cd0608270007gc6a919fx9e36562d8023635d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please copy relevant mailing lists and maintainers on bug reports.

On Sun, 27 Aug 2006 00:07:50 -0700
"Miles Lane" <miles.lane@gmail.com> wrote:

> I have a:
>=20
> eth0: RealTek RTL8139 at 0xf8fa2800, 00:c0:9f:95:18:1b, IRQ 10
> eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
>=20
> and a:
>=20
> ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.1.2kd
> ipw2200: Copyright(c) 2003-2006 Intel Corporation
> ipw2200: Detected Intel PRO/Wireless 2200BG Network Connection
> ipw2200: Detected geography ZZM (11 802.11bg channels, 0 802.11a chan=
nels)
>=20
> My dmesg output includes:
> w<8E>^U<C1>: link down
> NET: Registered protocol family 10
> lo: Disabled Privacy Extensions
> ADDRCONF(NETDEV_UP): w<8E>^U<C1>: link is not ready
>=20
> As you can see, one of my network cards is getting "w<8E>^U<C1>" as a
> device name.  This isn't the actual string.  Here's what I get by
> cutting and pasting from iwconfig: "w=EF=BF=BD"
>=20
> ifconfig shows:
> HWaddr 00:C0:9F:95:18:1B
>           UP BROADCAST MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>           Interrupt:10 Base address:0x2800
>=20
> In most of my builds it has been the ipw2200 which gets busted by thi=
s
> problem.  This time, ifconfig sees eth1 and not eth0.  Oddly, dmesg
> output includes:
> eth0: RealTek RTL8139 at 0xf8fa2800, 00:c0:9f:95:18:1b, IRQ 10
> eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
> so I am puzzled at the disappearance of eth0 from the ifconfig output=
=2E

Jeremy reported that a while back too.  I do not know what is causing i=
t
and as far as I know no net developers have yet looked into it.

