From: Martin Steigerwald <Martin@lichtvoll.de>
Subject: Re: bugs/regressions: report in LKML or in bugzilla?
Date: Tue, 7 Dec 2010 22:28:57 +0100
Message-ID: <201012072228.58728.Martin@lichtvoll.de>
References: <201012071639.58884.Martin@lichtvoll.de> <1291738321.2695.338.camel@edumazet-laptop> <1291755776.21627.13.camel@bwh-desktop> (sfid-20101207_222742_371812_FB136C88)
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3342038.kvo7sWBCtT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291755776.21627.13.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3342038.kvo7sWBCtT
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Am Dienstag 07 Dezember 2010 schrieb Ben Hutchings:
> On Tue, 2010-12-07 at 17:12 +0100, Eric Dumazet wrote:
> > Le mardi 07 d=C3=A9cembre 2010 =C3=A0 16:39 +0100, Martin Steigerwald a=
 =C3=A9crit :
> > > A participant of a linux performance training I hold found a bug
> > > with window scaling which did not receive any reply as well:
> > >=20
> > > Bug 20312 -  System freeze with multiples of 32 in
> > > /proc/sys/net/ipv4/tcp_adv_win_scale
> > > https://bugzilla.kernel.org/show_bug.cgi?id=3D20312
> >=20
> > User bug ?
> >=20
> > Documentation/networking/ip-sysctl.txt
> >=20
> > tcp_adv_win_scale - INTEGER
> >=20
> > 	Count buffering overhead as bytes/2^tcp_adv_win_scale
> > 	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
> > 	if it is <=3D 0.
> > 	Default: 2
> >=20
> > Given we use 32bit numbers, using values outside of [-31 ... 31]
> > makes litle sense.
> >=20
> > We could add sysctl range limit, but user should not mess with
> > /proc/sys/net/ipv4/parameters unless he knows what he is doing ?
>=20
> [...]
>=20
> For mere humans, the range is not quite os obvious.  Which is why this
> has been fixed in net-2.6 (as noted on that bug report now).
>=20
> Ben.

I verified the fix on 2.6.37-rc5.

Thanks,
=2D-=20
Martin 'Helios' Steigerwald - http://www.Lichtvoll.de
GPG: 03B0 0D6C 0040 0710 4AFA  B82F 991B EAAC A599 84C7

--nextPart3342038.kvo7sWBCtT
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkz+pxoACgkQmRvqrKWZhMfU/gCcDn8kM0h9tOb4zhIyJjh8qk3w
DSoAn3GjKynlP+g9DAdZlEnjE3Xr2/Ox
=/N3z
-----END PGP SIGNATURE-----

--nextPart3342038.kvo7sWBCtT--
