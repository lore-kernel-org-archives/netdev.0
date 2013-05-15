From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 01/36] net: can: at91_can: remove unnecessary platform_set_drvdata()
Date: Wed, 15 May 2013 11:04:06 +0200
Message-ID: <51934F86.2020301@pengutronix.de>
References: <000901ce4ad8$f32ac1a0$d98044e0$@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2EVARWROLLNKFRMIWNRLJ"
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	'Ludovic Desroches' <ludovic.desroches@atmel.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43342 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab3EOJEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 05:04:15 -0400
In-Reply-To: <000901ce4ad8$f32ac1a0$d98044e0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2EVARWROLLNKFRMIWNRLJ
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 05/07/2013 06:11 AM, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdec=
b4d
> (device-core: Ensure drvdata =3D NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL=
=2E
>=20
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Thanks, applied all 4 (1, 2, 3, 4) net: can: patches.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2EVARWROLLNKFRMIWNRLJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGTT4YACgkQjTAFq1RaXHN2RACdEYXisg5/t13/dCNH8qGg1dWQ
Kj0AoJR3HptzVmuRyySL8vs/tFDFwOeM
=/2BQ
-----END PGP SIGNATURE-----

------enig2EVARWROLLNKFRMIWNRLJ--
