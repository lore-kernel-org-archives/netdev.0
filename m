From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 079/493] can: remove use of __devexit_p
Date: Mon, 19 Nov 2012 19:45:56 +0100
Message-ID: <50AA7E64.6060707@pengutronix.de>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-79-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9ED5972BE9D4369FB7F1E9B7"
Cc: gregkh@linuxfoundation.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1353349642-3677-79-git-send-email-wfp5p@virginia.edu>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9ED5972BE9D4369FB7F1E9B7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/19/2012 07:20 PM, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
> needed.
>=20
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Wolfgang Grandegger <wg@grandegger.com>=20
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>=20
> Cc: linux-can@vger.kernel.org=20
> Cc: netdev@vger.kernel.org=20

In net-next/master are two patches, a new driver and support for more
hardware:

> 6cec9b0 can: grcan: Add device driver for GRCAN and GRHCAN cores
> e4bc6c0 can: sja1000: plx_pci: add support for Connect Tech Inc's Canpr=
o/104-Plus Opto CAN board

=2E..so you've missed these:

> ./grcan.c:1662:static int __devinit grcan_probe(struct platform_device =
*ofdev)
> ./grcan.c:1717:static int __devexit grcan_remove(struct platform_device=
 *ofdev)
> ./grcan.c:1732:static struct of_device_id grcan_match[] __devinitconst =
=3D {
> ./grcan.c:1749: .remove =3D __devexit_p(grcan_remove),
> ./sja1000/plx_pci.c:229:static struct plx_pci_card_info plx_pci_card_in=
fo_cti __devinitdata =3D {

I can create the missing patches and push them mainline via the net-next
tree.

Otherwise...Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig9ED5972BE9D4369FB7F1E9B7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlCqfmQACgkQjTAFq1RaXHPf8ACgg0tWWLLTnzrcosf7IqIv7JIE
JbYAn1IykaXnSgiBy0AmO74e/Hd2Wh3g
=Vz6N
-----END PGP SIGNATURE-----

--------------enig9ED5972BE9D4369FB7F1E9B7--
