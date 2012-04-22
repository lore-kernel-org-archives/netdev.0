From: Bill Fink <billfink@mindspring.com>
Subject: Re: rx_dropped packets stop with tcpdump running
Date: Sun, 22 Apr 2012 01:13:54 -0400
Message-ID: <20120422011354.623b08d4.billfink@mindspring.com>
References: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>
	<1334841865.2395.177.camel@edumazet-glaptop>
	<1334842088.2395.178.camel@edumazet-glaptop>
	<061C8A8601E8EE4CA8D8FD6990CEA8910FF2D23F@ORSMSX102.amr.corp.intel.com>
	<DUB108-W45246BF22ED8BAB93B78C8B2220@phx.gbl>
	<4F9179E3.5020507@hp.com>
	<DUB108-W57C2F8FCF145C20E3B8BF1B2220@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <brian.haley@hp.com>, <tushar.n.dave@intel.com>,
	<netdev@vger.kernel.org>, <eric.dumazet@gmail.com>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:57176 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752291Ab2DVFXO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Apr 2012 01:23:14 -0400
In-Reply-To: <DUB108-W57C2F8FCF145C20E3B8BF1B2220@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Apr 2012 17:25:28 +0200, Marco Berizzi wrote:

> brian.haley@hp.com wrote:
> > 0x886d or 0x86DD? That second one is IPv6, you might just need to l=
oad the module.
>=20
> here is the tcpdump:
>=20
> 17:23:25.561398 00:19:99:90:ba:72 > ff:ff:ff:ff:ff:ff, ethertype Unkn=
own (0x886d), length 64:=20
> =A0=A0=A0=A0=A0=A0=A0 0x0000:=A0 0001 0001 000c 24e2 0001 0019 9990 b=
a72=A0 ......$........r
> =A0=A0=A0=A0=A0=A0=A0 0x0010:=A0 0000 0500 2304 6364 726f 447b d700 8=
0f8=A0 ....#.cdroD{....
> =A0=A0=A0=A0=A0=A0=A0 0x0020:=A0 ffff 20d1 b631 80fa ffff e02b fb30 8=
0fa=A0 .....1.....+.0..
> =A0=A0=A0=A0=A0=A0=A0 0x0030:=A0 ffff=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 ..
> 17:23:25.561402 00:19:99:90:ba:73 > ff:ff:ff:ff:ff:ff, ethertype Unkn=
own (0x886d), length 64:=20
> =A0=A0=A0=A0=A0=A0=A0 0x0000:=A0 0001 0001 000c 24e2 0002 0019 9990 b=
a72=A0 ......$........r
> =A0=A0=A0=A0=A0=A0=A0 0x0010:=A0 6700 5400 6800 7200 6500 7300 6800 6=
f00=A0 g.T.h.r.e.s.h.o.
> =A0=A0=A0=A0=A0=A0=A0 0x0020:=A0 6c00 6400 0000 3700 3200 0000 0000 0=
000=A0 l.d...7.2.......
> =A0=A0=A0=A0=A0=A0=A0 0x0030:=A0 0000=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 ..

=46YI, a Google search for "ethertype 886d" revealed that this is
supposedly an Intel ANS probe.  See:

  http://fixunix.com/networking/337443-packets-broadcasting-every-secon=
d.html

						-Bill
