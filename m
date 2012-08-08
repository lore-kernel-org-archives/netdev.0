From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can/softing: Fix potential memory leak in softing_load_fw()
Date: Wed, 08 Aug 2012 19:18:02 +0200
Message-ID: <50229F4A.3010002@pengutronix.de>
References: <1344438901-25005-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1E3FA5183655B02D06137DED"
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344438901-25005-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1E3FA5183655B02D06137DED
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2012 05:15 PM, Alexey Khoroshilov wrote:
> Do not leak memory by updating pointer with potentially NULL realloc re=
turn value.
>=20
> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Thanks for the work,
applied to can/master.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig1E3FA5183655B02D06137DED
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAlAin0oACgkQjTAFq1RaXHPaiQCeN/jNtWYyGKc9JT8hlY7re9dI
teoAn1LCRd0QVsy03TJqalQjowDfxE22
=KS42
-----END PGP SIGNATURE-----

--------------enig1E3FA5183655B02D06137DED--
