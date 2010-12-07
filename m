From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: bugs/regressions: report in LKML or in bugzilla?
Date: Tue, 07 Dec 2010 21:02:56 +0000
Message-ID: <1291755776.21627.13.camel@bwh-desktop>
References: <201012071639.58884.Martin@lichtvoll.de>
	 <1291738321.2695.338.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Martin Steigerwald <Martin@lichtvoll.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291738321.2695.338.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-12-07 at 17:12 +0100, Eric Dumazet wrote:
> Le mardi 07 d=C3=A9cembre 2010 =C3=A0 16:39 +0100, Martin Steigerwald=
 a =C3=A9crit :
>=20
> > A participant of a linux performance training I hold found a bug wi=
th=20
> > window scaling which did not receive any reply as well:
> >=20
> > Bug 20312 -  System freeze with multiples of 32 in=20
> > /proc/sys/net/ipv4/tcp_adv_win_scale
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D20312
> >=20
>=20
> User bug ?
>=20
> Documentation/networking/ip-sysctl.txt
>=20
> tcp_adv_win_scale - INTEGER
> 	Count buffering overhead as bytes/2^tcp_adv_win_scale=20
> 	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
> 	if it is <=3D 0.
> 	Default: 2
>=20
> Given we use 32bit numbers, using values outside of [-31 ... 31] make=
s litle sense.
>=20
> We could add sysctl range limit, but user should not mess with=20
> /proc/sys/net/ipv4/parameters unless he knows what he is doing ?
[...]

=46or mere humans, the range is not quite os obvious.  Which is why thi=
s
has been fixed in net-2.6 (as noted on that bug report now).

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
