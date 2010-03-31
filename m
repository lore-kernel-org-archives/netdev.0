From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH][V2] MACB: Set PHY address in kernel parameters
Date: Wed, 31 Mar 2010 11:48:26 +0200
Message-ID: <4BB31A6A.1000503@pengutronix.de>
References: <1270025218-7245-1-git-send-email-anders.darander@gmail.com> <4BB31345.5050101@pengutronix.de> <20100331093956.GI4837@datarespons.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE182812377EC455E0692276B"
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Erik Waling <erik.waling@konftel.com>,
	Patrick McHardy <kaber@trash.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anders Darander <anders.darander@datarespons.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41404 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755925Ab0CaJsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 05:48:42 -0400
In-Reply-To: <20100331093956.GI4837@datarespons.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE182812377EC455E0692276B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Anders Darander wrote:
> * Marc Kleine-Budde <mkl@pengutronix.de> [100331 11:18]:
>> We're using phy_mask in one of our projects, it's still using 2.6.29,
>> though. I think it's worth testing if it's still working.
>=20
> Well, that was obviously something I overlooked / misinterpreted when I=

> tried to solve our problem!
>=20
> As I understand it, phy_mask is a bitfield for setting which PHYs shoul=
d
> be enabled... Then this should have worked OK for us!

Yes, it's a bitmask of PHYs that should be probed.

>> static struct at91_eth_data __initdata p298_macb_data =3D {
>>        .is_rmii        =3D 0,
>>        .phy_mask       =3D ~(1 << 8),
>> };
>=20
>> at91_add_device_eth(&p298_macb_data);
>=20
> I've not tested it, but it should probably have worked.

Cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigE182812377EC455E0692276B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkuzGm0ACgkQjTAFq1RaXHP/LwCffHp5r4vbIXqApoISTtG0iEvH
XOAAoIikIu69SmyOExQt6vXU2UWsXR9X
=k7tM
-----END PGP SIGNATURE-----

--------------enigE182812377EC455E0692276B--
