From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Sat, 29 Jan 2005 04:15:43 -0500
Message-ID: <200501290915.j0T9FkVY012948@turing-police.cc.vt.edu>
References: <1106932637.3778.92.camel@localhost.localdomain> <20050128100229.5c0e4ea1@dxpl.pdx.osdl.net> <1106937110.3864.5.camel@localhost.localdomain> <20050128105217.1dc5ef42@dxpl.pdx.osdl.net> <1106944492.3864.30.camel@localhost.localdomain>
            <1106945266.7776.41.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1106990142_21005P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Lorenzo =?ISO-8859-1?Q?Hern=E1ndez_?=
	 =?ISO-8859-1?Q?Garc=EDa-Hierro?= <lorenzo@gnu.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com,
	Hank Leininger <hlein@progressive-comp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262883AbVA2JQp@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: Your message of "Fri, 28 Jan 2005 21:47:45 +0100."
             <1106945266.7776.41.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1106990142_21005P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Fri, 28 Jan 2005 21:47:45 +0100, Arjan van de Ven said:

> as for obsd_get_random_long().. would it be possible to use the
> get_random_int() function from the patches I posted the other day? They=

> use the existing random.c infrastructure instead of making a copy...
>=20
> I still don't understand why you need a obsd_rand.c and can't use the
> normal random.c

Note that obsd_rand.c started off life as a BSD-licensed file - I was tol=
d
that was a show-stopper when I submitted basically the same patch a while=
 back.

So re-working it to use get_random_int()  would be a good idea, I think..=
..

--==_Exmh_1106990142_21005P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFB+1Q9cC3lWbTT17ARAsKUAJ9p3+YEyq2ZOwNJSAN1VG36ZEkVOgCg8zvs
6EfUPjw0Y9WR6GK3azrO7WQ=
=7riU
-----END PGP SIGNATURE-----

--==_Exmh_1106990142_21005P--
