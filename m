From: Harald Welte <laforge@gnumonks.org>
Subject: xfrm_user.c doesn't use NLMSG_F_MULTI
Date: Wed, 13 Oct 2004 10:07:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041013080705.GB3387@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="i0/AhcQY5QxfSsSZ"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

If I send a GETSA with NLM_F_DUMP message from userspace, I receive a
batch of SA messages, but they apparently don't have the F_MULTI flag
set.=20

Aren't they (all but the last msg) supposed to have the usual F_MULTI ?
Is this by intention or a mistake?

Cheers,
	Harald

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--i0/AhcQY5QxfSsSZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBbOIpXaXGVTD0i/8RAts9AKCL5A0lvctx+lRkf6odyzpyGxdycQCfYDeO
w3W1JDC8LXCVZNQo2uWvWCI=
=z4Hi
-----END PGP SIGNATURE-----

--i0/AhcQY5QxfSsSZ--
