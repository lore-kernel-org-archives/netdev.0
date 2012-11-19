From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 333/493] net: remove use of __devinitdata
Date: Mon, 19 Nov 2012 19:50:49 +0100
Message-ID: <50AA7F89.1020504@pengutronix.de>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-333-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE7DB2B6D387D3DC5400C6E07"
Cc: gregkh@linuxfoundation.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-hippi@sunsite.dk, linux-wireless@vger.kernel.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1353349642-3677-333-git-send-email-wfp5p@virginia.edu>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE7DB2B6D387D3DC5400C6E07
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/19/2012 07:24 PM, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devinitdata is no
> longer needed.
>=20
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Wolfgang Grandegger <wg@grandegger.com>=20
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>=20
> Cc: "Maciej W. Rozycki" <macro@linux-mips.org>=20
> Cc: Jes Sorensen <jes@trained-monkey.org>=20
> Cc: "John W. Linville" <linville@tuxdriver.com>=20
> Cc: Larry Finger <Larry.Finger@lwfinger.net>=20
> Cc: Chaoming Li <chaoming_li@realsil.com.cn>=20
> Cc: linux-can@vger.kernel.org=20
> Cc: netdev@vger.kernel.org=20
> Cc: linux-hippi@sunsite.dk=20
> Cc: linux-wireless@vger.kernel.org=20

You've missed (mainlined via net-next/master):
> ./sja1000/plx_pci.c:229:static struct plx_pci_card_info plx_pci_card_in=
fo_cti __devinitdata =3D {

Otherwise...
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de> (for the CAN part)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigE7DB2B6D387D3DC5400C6E07
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlCqf4kACgkQjTAFq1RaXHPGvACdG0eLBLrkna9F93jnuxcADGQB
u6YAnjaWLnG+qswOL22ZSiaRWz3mVRob
=77FE
-----END PGP SIGNATURE-----

--------------enigE7DB2B6D387D3DC5400C6E07--
