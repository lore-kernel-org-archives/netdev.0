From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Wed, 04 Nov 2009 21:33:12 -0500
Message-ID: <6025.1257388392@turing-police.cc.vt.edu>
References: <5765.1257270611@turing-police.cc.vt.edu> <4AF07024.80103@gmail.com> <4AF08292.7090102@codefidence.com> <Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI> <7916.1257300093@turing-police.cc.vt.edu>
            <4AF1AF28.2030106@codefidence.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1257388392_4430P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: =?windows-1252?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ori Finkelman <ori@comsleep.com>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755320AbZKECd6@vger.kernel.org>
In-Reply-To: Your message of "Wed, 04 Nov 2009 18:43:20 +0200."
             <4AF1AF28.2030106@codefidence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1257388392_4430P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, 04 Nov 2009 18:43:20 +0200, Gilad Ben-Yossef said:

> OK, I thing I've got it.
>=20
> Kindly try the next patch. It goes on top (in addition to) the previous=
=20
> one. This should fix the crash.

OK. much better.  Have been up for about 25 minutes now, and fetchmail ha=
s
pulled down e-mail several times, and no proboems seen.

> There is still some small cruft in the handling of the per route TCP
> options for IPv6 left, which means that the per route options might get=
=20
> ignored for
> incoming IPv6 connections right now. I will fix this if this works.

Yell if you want something tested. ;)

--==_Exmh_1257388392_4430P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFK8jlocC3lWbTT17ARAksWAJ44jUJb0L8DbE4WmHfOIJs6AU89IQCg7W1u
Z8LT0ZYlWPucVQe8d5ps5bg=
=H/XB
-----END PGP SIGNATURE-----

--==_Exmh_1257388392_4430P--
