From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: sun4i_handle_irq: WARNING at net/ipv4/tcp_input.c:2711
 tcp_fastretrans_alert
Date: Fri, 23 Aug 2013 20:21:16 +0200
Message-ID: <20130823182116.GE1230@lukather>
References: <20130821094432.GA28249@lnx-rg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0QFb0wBpEddLcDHQ"
Cc: Stefan Roese <sr@denx.de>, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Richard GENOUD <richard.genoud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:51988 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756046Ab3HWSVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 14:21:31 -0400
Content-Disposition: inline
In-Reply-To: <20130821094432.GA28249@lnx-rg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0QFb0wBpEddLcDHQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Richard,

On Wed, Aug 21, 2013 at 11:47:20AM +0200, Richard GENOUD wrote:
> Hi Maxime, Stephan
>=20
> I just realise that, *sometimes*, I have some warnings on my cubieboard
> (6 since the 22 of july, and the board is runnning 24/24).

Wow, I'm impressed it worked this fine actually :)

> It has happened also on 3.10 + emac patches.
> Here it is:
> [27224.060000] ------------[ cut here ]------------
> [27224.070000] WARNING: CPU: 0 PID: 0 at net/ipv4/tcp_input.c:2711 tcp_fa=
stretrans_alert+0x717/0x734()
> [27224.080000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.0-rc6-00010-g=
54f11ec #8
> [27224.080000] [<c000f231>] (unwind_backtrace+0x1/0x98) from [<c000e2b7>]=
 (show_stack+0xb/0xc)
> [27224.090000] [<c000e2b7>] (show_stack+0xb/0xc) from [<c0013cd3>] (warn_=
slowpath_common+0x43/0x5c)
> [27224.100000] [<c0013cd3>] (warn_slowpath_common+0x43/0x5c) from [<c0013=
d6d>] (warn_slowpath_null+0x11/0x14)
> [27224.110000] [<c0013d6d>] (warn_slowpath_null+0x11/0x14) from [<c015ead=
f>] (tcp_fastretrans_alert+0x717/0x734)
> [27224.120000] [<c015eadf>] (tcp_fastretrans_alert+0x717/0x734) from [<c0=
15f32b>] (tcp_ack+0x6af/0x984)
> [27224.130000] [<c015f32b>] (tcp_ack+0x6af/0x984) from [<c015fcab>] (tcp_=
rcv_established+0x93/0x3ec)
> [27224.140000] [<c015fcab>] (tcp_rcv_established+0x93/0x3ec) from [<c0165=
621>] (tcp_v4_do_rcv+0xa1/0x160)
> [27224.150000] [<c0165621>] (tcp_v4_do_rcv+0xa1/0x160) from [<c0167129>] =
(tcp_v4_rcv+0x4e9/0x500)
> [27224.160000] [<c0167129>] (tcp_v4_rcv+0x4e9/0x500) from [<c015025d>] (i=
p_local_deliver_finish+0x79/0x180)
> [27224.170000] [<c015025d>] (ip_local_deliver_finish+0x79/0x180) from [<c=
01500a1>] (ip_rcv_finish+0xc9/0x20c)
> [27224.180000] [<c01500a1>] (ip_rcv_finish+0xc9/0x20c) from [<c0129493>] =
(__netif_receive_skb_core+0x287/0x3dc)
> [27224.190000] [<c0129493>] (__netif_receive_skb_core+0x287/0x3dc) from [=
<c0129a8b>] (process_backlog+0x5b/0xd0)
> [27224.200000] [<c0129a8b>] (process_backlog+0x5b/0xd0) from [<c012bc6f>]=
 (net_rx_action+0x5f/0xe8)
> [27224.200000] [<c012bc6f>] (net_rx_action+0x5f/0xe8) from [<c0015fc9>] (=
__do_softirq+0x91/0x134)
> [27224.210000] [<c0015fc9>] (__do_softirq+0x91/0x134) from [<c0016251>] (=
irq_exit+0x59/0x80)
> [27224.220000] [<c0016251>] (irq_exit+0x59/0x80) from [<c000d00d>] (handl=
e_IRQ+0x21/0x54)
> [27224.230000] [<c000d00d>] (handle_IRQ+0x21/0x54) from [<c00083ef>] (sun=
4i_handle_irq+0x1f/0x30)
> [27224.240000] [<c00083ef>] (sun4i_handle_irq+0x1f/0x30) from [<c000ea1b>=
] (__irq_svc+0x3b/0x5c)
> [27224.250000] Exception stack(0xc0287f70 to 0xc0287fb8)
> [27224.250000] 7f60:                                     00000000 0000000=
0 00000000 00000000
> [27224.260000] 7f80: c0286000 c02ad7fd 00000001 c02ad7fd c028e084 413fc08=
2 00000000 00000000
> [27224.270000] 7fa0: 01000000 c0287fb8 c000d115 c000d116 40000033 ffffffff
> [27224.270000] [<c000ea1b>] (__irq_svc+0x3b/0x5c) from [<c000d116>] (arch=
_cpu_idle+0x16/0x1c)
> [27224.280000] [<c000d116>] (arch_cpu_idle+0x16/0x1c) from [<c002e69d>] (=
cpu_startup_entry+0x35/0xa0)
> [27224.290000] [<c002e69d>] (cpu_startup_entry+0x35/0xa0) from [<c026f75f=
>] (start_kernel+0x1af/0x1f0)
> [27224.300000] ---[ end trace 15641276e08fba8a ]---

Hmmm, that seems pretty far from the network/interrupt drivers, and it
looks like other users have seen this on !ARM machines:
http://forums.gentoo.org/viewtopic-p-7379928.html
https://bugzilla.redhat.com/show_bug.cgi?id=3D989251

There's a patch in the redhat's bugzilla, could you try to apply it and
see if it solves your problem?

Maybe the netdev guys will have other ideas as well.

Thanks,
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--0QFb0wBpEddLcDHQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJSF6gcAAoJEBx+YmzsjxAgwDAQAJfOpONxa40XQLhP35NvHJNx
rU6C1k/joJEBr1VvMefmwricdv3YIDMjMUCU/ZJ2v7ODyLr6m/owflAKJJIxBXBW
oWkEPIzs7XfBzLkOU5rvPL9AnK0pl6qsAGc/BPKCOOw0dpsV9E0ekCdg5J6LLZre
V2yzlGqrldFn/qsnyBIRt+jAiaPSFhkMxP1JYp2cnUZqOKTH7blvmWZNrFdX5WSF
WpMS0w0rU4lR5KEaU4I36gpcW4YwoyUpS7Jh3WkmbXCbw+c6EvF6alkaPgZ4nGNa
kgEhhPZduWSS5++5DD3B2yRcTF/z4+0lJ6JSIK5E+xjXOvGnbnnZCvLIB4KZuq5L
6dlmVUHSm8xzcCPvhZHof8IlvZ27BVX/fS9FsjMWRCfzwjyKe2tea9aG3GVo9cjs
9z5c03kKZOzJ0mLEeDr19RF2N4Pd+DwI+O/ifJPktyBGCaXE3sbSb6CCZDeLvXN7
0T2XMJXsHTT3K+HdiWDMQdaPUvIH9nOK5RWYA3vqy9YYYU4b/ry3RU5PPOPrGSSj
t8VOEkPO4rnJqtPpfvY3cXVanEv5hjH2ghhgggnKbHkitnSDbGVgHKNjIXG9nE3G
9cUHwe4sRsHzNro3vwxv/7Qb6lrH6GR+B6QG/Zzp3D15aQPUrafWgSvUoGths1Gr
Yv7rA5XZf6xxFmeVMjbk
=uXmr
-----END PGP SIGNATURE-----

--0QFb0wBpEddLcDHQ--
