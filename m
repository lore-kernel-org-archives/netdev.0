From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write APIs for
 BE instances
Date: Wed, 25 Jun 2014 12:34:20 +0200
Message-ID: <53AAA5AC.5070707@pengutronix.de>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com> <53AA8805.3050309@pengutronix.de> <ae6e49865206432ea871b08b159bae55@BN1PR03MB220.namprd03.prod.outlook.com> <063D6719AE5E284EB5DD2968C1650D6D17264BA8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="OGTPKaQx5lmaie8UiDI7VtFXP7w8GrWhW"
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"'bhupesh.sharma@freescale.com'" <bhupesh.sharma@freescale.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17264BA8@AcuExch.aculab.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OGTPKaQx5lmaie8UiDI7VtFXP7w8GrWhW
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/25/2014 12:29 PM, David Laight wrote:
>> Ok. Or should I create two functions for read and write - one does it =
in LE way and the other
>> in BE way and parse the DT to understand which endianness the module s=
upports.
>=20
> An indirect call is likely to be slower than a conditional.
> The conditional inside a non-inlined function is likely to get
> predicted correctly on any code paths that matter.
> Unfortunately using a real function increases register pressure.
>=20
> Maybe a compile-time option for BE, LE or both.
> So a 'generic' kernel can work, but a SoC specific one will be faster.
> Then have the driver load/attach/init fail if it is the wrong endiannes=
s.

Don't overengineer, CAN is max 1 MiB/s.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--OGTPKaQx5lmaie8UiDI7VtFXP7w8GrWhW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOqpawACgkQjTAFq1RaXHOdmwCfbFjxp5NMshjUlHjNMl7M/DkP
DRkAn32Nj/aU2b3V4BucV0yRSHCGtaDy
=NUXJ
-----END PGP SIGNATURE-----

--OGTPKaQx5lmaie8UiDI7VtFXP7w8GrWhW--
