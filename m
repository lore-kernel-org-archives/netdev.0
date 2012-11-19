From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 379/493] net: remove use of __devinitconst
Date: Mon, 19 Nov 2012 19:51:47 +0100
Message-ID: <50AA7FC3.8060905@pengutronix.de>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-379-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig50DA8157DA398FBB356357B5"
Cc: gregkh@linuxfoundation.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Luciano Coelho <coelho@ti.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1353349642-3677-379-git-send-email-wfp5p@virginia.edu>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig50DA8157DA398FBB356357B5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/19/2012 07:25 PM, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devinitconst is no
> longer needed.
>=20
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Wolfgang Grandegger <wg@grandegger.com>=20
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>=20
> Cc: Luciano Coelho <coelho@ti.com>=20
> Cc: "John W. Linville" <linville@tuxdriver.com>=20
> Cc: linux-can@vger.kernel.org=20
> Cc: netdev@vger.kernel.org=20
> Cc: linux-wireless@vger.kernel.org=20

You've missed (mainlined via net-next/master):
> ./grcan.c:1732:static struct of_device_id grcan_match[] __devinitconst =
=3D {

Otherwise...
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de> (for the CAN part)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig50DA8157DA398FBB356357B5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlCqf8MACgkQjTAFq1RaXHOGwgCfc2mmGrH8Mai0AYPG5N/mIhq2
eKcAn3ho/MPfbYVKuNNprlnYMSJ2h1ll
=3DaY
-----END PGP SIGNATURE-----

--------------enig50DA8157DA398FBB356357B5--
