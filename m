From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: ems_usb: fix urb leaks on failure paths
Date: Mon, 09 Dec 2013 11:45:59 +0100
Message-ID: <52A59F67.7060008@pengutronix.de>
References: <1386371435-17597-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="8x4v4XrLHekBw42bbav4o8D45lMNw3pRf"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1386371435-17597-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8x4v4XrLHekBw42bbav4o8D45lMNw3pRf
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/07/2013 12:10 AM, Alexey Khoroshilov wrote:
> There are a couple failure paths where urb leaks.
> Is spare code within ems_usb_start_xmit(),
> usb_free_urb() should be used to deallocate urb instead of usb_unanchor=
_urb().
> In ems_usb_start() there is no usb_free_urb() if usb_submit_urb() fails=
=2E
>=20
> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied to the can-tree.

Thx, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--8x4v4XrLHekBw42bbav4o8D45lMNw3pRf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKln2cACgkQjTAFq1RaXHP1+QCdHK4Lx9tQ2zf25u2PnqGQeo9y
pswAnRTHbjBrmdE/ducyCI1bIp/htdvN
=arqc
-----END PGP SIGNATURE-----

--8x4v4XrLHekBw42bbav4o8D45lMNw3pRf--
