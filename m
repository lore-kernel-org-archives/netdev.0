From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 202/493] can: remove use of __devinit
Date: Mon, 19 Nov 2012 19:48:56 +0100
Message-ID: <50AA7F18.7070102@pengutronix.de>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-202-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig69DC3E3C0221C61AEC071FF7"
Cc: gregkh@linuxfoundation.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1353349642-3677-202-git-send-email-wfp5p@virginia.edu>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig69DC3E3C0221C61AEC071FF7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/19/2012 07:22 PM, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devinit is no longer
> needed.
>=20
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Wolfgang Grandegger <wg@grandegger.com>=20
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>=20
> Cc: linux-can@vger.kernel.org=20
> Cc: netdev@vger.kernel.org=20

You've missed (upstreamed via net-next/master):

=2E/grcan.c:1662:static int __devinit grcan_probe(struct platform_device
*ofdev)
=2E/grcan.c:1717:static int __devexit grcan_remove(struct platform_device=

*ofdev)

Otherwise...Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig69DC3E3C0221C61AEC071FF7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlCqfxgACgkQjTAFq1RaXHM7pQCeJFt0pHPf3d/gZLk3gPIVUkrm
xlcAn0Nw3vxO+m6l3cDVR3wykygx8GZ8
=Vssv
-----END PGP SIGNATURE-----

--------------enig69DC3E3C0221C61AEC071FF7--
