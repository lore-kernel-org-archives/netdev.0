From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting hook
Date: Sat, 14 Feb 2004 19:37:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040214183743.GO7756@sunbeam.de.gnumonks.org>
References: <Xine.LNX.4.44.0402141318490.6128-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H83aLI5Lttn3Hg7B"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0402141318490.6128-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--H83aLI5Lttn3Hg7B
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Feb 14, 2004 at 01:37:23PM -0500, James Morris wrote:
> This patch fixes a bug with with multicast/broadcast packets,
> Netfilter, and NICs which do hardware checksums.
>=20
> Please review.
=20
I'm fine with that patch, James.

Maybe it's worth adding a short one-line comment stating why a clone is
not sufficient here.

> James Morris

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--H83aLI5Lttn3Hg7B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFALmr3XaXGVTD0i/8RAnMfAJwIV/1bsCPYktMCi2e11ppj01ry1gCgjvGf
6gckEOaCSnl2lAGM3xtNuW0=
=tRAy
-----END PGP SIGNATURE-----

--H83aLI5Lttn3Hg7B--
