From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 02/36] net: can: c_can: remove unnecessary platform_set_drvdata()
Date: Tue, 07 May 2013 09:07:45 +0200
Message-ID: <5188A841.4010507@pengutronix.de>
References: <000d01ce4ad9$54f93560$feeba020$@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2QOEASTBPONDDKGXQXCSJ"
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	'AnilKumar Ch' <anilkumar@ti.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40217 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757012Ab3EGHHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 03:07:54 -0400
In-Reply-To: <000d01ce4ad9$54f93560$feeba020$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2QOEASTBPONDDKGXQXCSJ
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 05/07/2013 06:14 AM, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdec=
b4d
> (device-core: Ensure drvdata =3D NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL=
=2E
>=20
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2QOEASTBPONDDKGXQXCSJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGIqEEACgkQjTAFq1RaXHMYSACfQTqqnL8aBH7qvkeN/OicRPGk
iR4AnA9cpzTQre509AK/j3fnmtzV9q2Z
=fKl3
-----END PGP SIGNATURE-----

------enig2QOEASTBPONDDKGXQXCSJ--
