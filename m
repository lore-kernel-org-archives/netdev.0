From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: pcan_usb_core: fix memory leak on failure paths
 in peak_usb_start()
Date: Fri, 06 Sep 2013 08:56:14 +0200
Message-ID: <52297C8E.70101@pengutronix.de>
References: <1378450379823688500@peak-system.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="L0Px724EDhVNthCLhfSF3CkAX8IXQTM73"
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Stephane Grosjean <s.grosjean@peak-system.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378450379823688500@peak-system.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--L0Px724EDhVNthCLhfSF3CkAX8IXQTM73
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/06/2013 08:52 AM, Stephane Grosjean wrote:
> Tx and rx urbs are not deallocated if something goes wrong in peak_usb_=
start().
> The patch fixes error handling to deallocate all the resources.
>=20
> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> Acked-by: Stephane Grosjean <s.grosjean@peak-system.com>

Tnx,
Marc

BTW: A simply reply to the original patch with your Acked-by is sufficien=
t.

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--L0Px724EDhVNthCLhfSF3CkAX8IXQTM73
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIpfI4ACgkQjTAFq1RaXHN/FwCgjFYA+SZ2ODnXjZG3GA+48XOu
ktMAnRrV1hVQMrK4iAIkmXT4rbluRI4m
=ujBN
-----END PGP SIGNATURE-----

--L0Px724EDhVNthCLhfSF3CkAX8IXQTM73--
