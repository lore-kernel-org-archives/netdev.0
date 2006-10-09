From: Matthias Hentges <oe@hentges.net>
Subject: Re: [PATCH] sky2: revert pci express extensions
Date: Tue, 10 Oct 2006 01:47:51 +0200
Message-ID: <1160437671.4575.48.camel@mhcln03>
References: <20061009144038.6d3a93d6@freekitty>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-7cxOjPqITMoywcQKqEFJ"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hentges.net ([81.169.178.128]:7389 "EHLO
	h6563.serverkompetenz.net") by vger.kernel.org with ESMTP
	id S1751371AbWJIXrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 19:47:49 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061009144038.6d3a93d6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7cxOjPqITMoywcQKqEFJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hello Stephen,

Am Montag, den 09.10.2006, 14:40 -0700 schrieb Stephen Hemminger:
> The pci express error handling extensions don't work unless PCI access is=
 via=20
> mmconfig. Otherwise, all accesses to pci config registers greater than 25=
6 fail.
> Since the sky2 driver has other ways of getting to PCI config space, it w=
orks
> around this short coming, but the pci_find_ext_capablity doesn't work.
>=20
> This backs out commit 91aeb3edbcf4e6ed72d138ac8c22fd68e6d717c3
> Go back to hardcoding, since we know where the error registers are anyway=
.
> Fixes  http://bugzilla.kernel.org/show_bug.cgi?id=3D7222
>=20
> Signed-off-by: Stephen Hemminger <shemmminger@osdl.org>
>=20
[...]

thanks a lot for that one. Works perfectly fine and the annoying
error-messages are gone.
--=20
Matthias 'CoreDump' Hentges=20

My OS: Debian SID. Geek by Nature, Linux by Choice

--=-7cxOjPqITMoywcQKqEFJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Dies ist ein digital signierter Nachrichtenteil

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFKt+nAq2P5eLUP5IRAi9BAJ9l76OS9FbaobwhiABHbCgXW9XQYwCfdZic
kDb0EvrKiUW+/JL9MHjEg3Q=
=kuVd
-----END PGP SIGNATURE-----

--=-7cxOjPqITMoywcQKqEFJ--

