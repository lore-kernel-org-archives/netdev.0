From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH][V2] MACB: Set PHY address in kernel parameters
Date: Wed, 31 Mar 2010 11:17:57 +0200
Message-ID: <4BB31345.5050101@pengutronix.de>
References: <1270025218-7245-1-git-send-email-anders.darander@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig859552936876718C43367115"
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Erik Waling <erik.waling@konftel.com>,
	Patrick McHardy <kaber@trash.net>,
	Anders Darander <ad@datarespons.se>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anders Darander <anders.darander@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53531 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933001Ab0CaJSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 05:18:21 -0400
In-Reply-To: <1270025218-7245-1-git-send-email-anders.darander@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig859552936876718C43367115
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Anders Darander wrote:
> From: Anders Darander <ad@datarespons.se>
>=20
> Add the possibility to set the phy address. This is needed if an integr=
ated
> switch is connected to the MAC, as it is often the case that the highes=
t port
> is the one connected to the MAC of the MCU.
>=20
> E.g. in the case of the Micrel KSZ8873, port 3 is the one to connect to=
 the
> MCU, thus, the MAC needs to connect to phy address 0x03, instead of the=
 first
> phy found.

We're using phy_mask in one of our projects, it's still using 2.6.29,
though. I think it's worth testing if it's still working.

static struct at91_eth_data __initdata p298_macb_data =3D {
       .is_rmii        =3D 0,
       .phy_mask       =3D ~(1 << 8),
};

at91_add_device_eth(&p298_macb_data);

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig859552936876718C43367115
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkuzE0kACgkQjTAFq1RaXHOWSwCfe4KjEgh3Cfju3ikZySkBoHHq
iOoAnRZE7V1ztWR2kSVXUs9ThmqjMpqh
=TZD2
-----END PGP SIGNATURE-----

--------------enig859552936876718C43367115--
