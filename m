From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 471/493] net: remove use of __devexit
Date: Mon, 19 Nov 2012 19:56:20 +0100
Message-ID: <50AA80D4.2010801@pengutronix.de>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-471-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBADFBE8D838AF90FAABB9667"
Cc: gregkh@linuxfoundation.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1353349642-3677-471-git-send-email-wfp5p@virginia.edu>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBADFBE8D838AF90FAABB9667
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/19/2012 07:27 PM, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devexit is no
> longer needed.
>=20
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Wolfgang Grandegger <wg@grandegger.com>=20
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>=20
> Cc: "Maciej W. Rozycki" <macro@linux-mips.org>=20
> Cc: Jes Sorensen <jes@trained-monkey.org>=20
> Cc: Samuel Ortiz <samuel@sortiz.org>=20
> Cc: Rusty Russell <rusty@rustcorp.com.au>=20
> Cc: "Michael S. Tsirkin" <mst@redhat.com>=20
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com>=20
> Cc: "VMware, Inc." <pv-drivers@vmware.com>=20
> Cc: Francois Romieu <romieu@fr.zoreil.com>=20
> Cc: Krzysztof Halasa <khc@pm.waw.pl>=20
> Cc: "John W. Linville" <linville@tuxdriver.com>=20
> Cc: Jiri Slaby <jirislaby@gmail.com>=20
> Cc: Nick Kossifidis <mickflemm@gmail.com>=20
> Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>=20
> Cc: Simon Kelley <simon@thekelleys.org.uk>=20
> Cc: Stefano Brivio <stefano.brivio@polimi.it>=20
> Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>=20
> Cc: Dan Williams <dcbw@redhat.com>=20
> Cc: Christian Lamparter <chunkeey@googlemail.com>=20
> Cc: Herton Ronaldo Krzesinski <herton@canonical.com>=20
> Cc: Hin-Tak Leung <htl10@users.sourceforge.net>=20
> Cc: Larry Finger <Larry.Finger@lwfinger.net>=20
> Cc: Luciano Coelho <coelho@ti.com>=20
> Cc: netdev@vger.kernel.org=20
> Cc: linux-can@vger.kernel.org=20
> Cc: linux-hippi@sunsite.dk=20
> Cc: virtualization@lists.linux-foundation.org=20
> Cc: linux-wireless@vger.kernel.org=20
> Cc: ath5k-devel@lists.ath5k.org=20
> Cc: b43-dev@lists.infradead.org=20
> Cc: libertas-dev@lists.infradead.org=20
> Cc: xen-devel@lists.xensource.com=20

You've missed (mainlined via net-next/master):
> ./grcan.c:1749: .remove =3D __devexit_p(grcan_remove),

Otherwise...
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de> (for the CAN part)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |




--------------enigBADFBE8D838AF90FAABB9667
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlCqgNgACgkQjTAFq1RaXHP/YACghhoqwXUnPrXs7UXlOxK4DRtY
4asAn3A7F5eRgSmkS1HMLuvOp8az6ktY
=vL6i
-----END PGP SIGNATURE-----

--------------enigBADFBE8D838AF90FAABB9667--
