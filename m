From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: usb_8dev: fix urb leak on failure path in usb_8dev_start()
Date: Fri, 19 Jul 2013 14:54:28 +0200
Message-ID: <51E93704.8010208@pengutronix.de>
References: <1374096033-28981-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2DVGJUTWSQJWSHLSWPGSO"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Bernd Krumboeck <krumboeck@universalnet.at>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1374096033-28981-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2DVGJUTWSQJWSHLSWPGSO
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/17/2013 11:20 PM, Alexey Khoroshilov wrote:
> If usb_8dev_start() fails to submit urb,
> it unanchors the urb but forgets to free it.
>=20
> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Thanks, added to can/fixes-for-3.11

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2DVGJUTWSQJWSHLSWPGSO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlHpNwUACgkQjTAFq1RaXHMPEQCfS4rpvy1qOf+x5FkrJl11uN/3
1SMAoIwF5db06bhxA3jRcISZDjnQq+yg
=34Hf
-----END PGP SIGNATURE-----

------enig2DVGJUTWSQJWSHLSWPGSO--
