From: Martin Steigerwald <Martin@lichtvoll.de>
Subject: Re: bugs/regressions: report in LKML or in bugzilla?
Date: Tue, 7 Dec 2010 22:11:39 +0100
Message-ID: <201012072211.40206.Martin@lichtvoll.de>
References: <201012071639.58884.Martin@lichtvoll.de> <1291738321.2695.338.camel@edumazet-laptop> (sfid-20101207_215851_097907_13E581D1)
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1359749.QxOZtP6rOC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291738321.2695.338.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1359749.QxOZtP6rOC
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Am Dienstag 07 Dezember 2010 schrieb Eric Dumazet:
> Le mardi 07 d=C3=A9cembre 2010 =C3=A0 16:39 +0100, Martin Steigerwald a =
=C3=A9crit :
> > A participant of a linux performance training I hold found a bug with
> > window scaling which did not receive any reply as well:
> >=20
> > Bug 20312 -  System freeze with multiples of 32 in
> > /proc/sys/net/ipv4/tcp_adv_win_scale
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D20312
>=20
> User bug ?

Sure, but whats the point?

> Documentation/networking/ip-sysctl.txt
>=20
> tcp_adv_win_scale - INTEGER
> 	Count buffering overhead as bytes/2^tcp_adv_win_scale
> 	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
> 	if it is <=3D 0.
> 	Default: 2
>=20
> Given we use 32bit numbers, using values outside of [-31 ... 31] makes
> litle sense.

Granted, it does not make sense. The user tried that on an exercise to=20
make TCP/IP networking in Linux as slow as possible (to understand why its=
=20
fast at all).

Still: Here isn't documented that the kernel freezes when writing a wrong=20
value in there.
=20
> We could add sysctl range limit, but user should not mess with
> /proc/sys/net/ipv4/parameters unless he knows what he is doing ?
>=20
> Almost all /proc/sys/net/ipv4/parameters dont have range limits and
> unexpected results with insane values feeded.

Well I disagree. Its a user interface, even tough a root user interface,=20
that is even writable without writing a program. And as far as I=20
understand even at least some system calls do some basic sanity checking=20
on arguments.

If it doesn't cost too much overhead, arguments in there should receive at=
=20
least some basic sanity checking.

> An other way to freeze a machine being root is :
>=20
> halt

It won't freeze the machine. It does a clean halt which reduces the chance=
=20
to reduce valuable data in yet unwritten pages.

And here it is documented that this will halt the machine.

Ciao,
=2D-=20
Martin 'Helios' Steigerwald - http://www.Lichtvoll.de
GPG: 03B0 0D6C 0040 0710 4AFA  B82F 991B EAAC A599 84C7

--nextPart1359749.QxOZtP6rOC
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkz+owwACgkQmRvqrKWZhMeI+gCfU7ykETyMB1/44zl4BVgRC1UP
H2MAoLLTv7uBajYFwMPodBTIxPYzPgH/
=irO0
-----END PGP SIGNATURE-----

--nextPart1359749.QxOZtP6rOC--
