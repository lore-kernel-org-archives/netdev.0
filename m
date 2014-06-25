From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write APIs for
 BE instances
Date: Wed, 25 Jun 2014 13:07:48 +0200
Message-ID: <53AAAD84.1010400@pengutronix.de>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com> <53AA8805.3050309@pengutronix.de> <ae6e49865206432ea871b08b159bae55@BN1PR03MB220.namprd03.prod.outlook.com> <53AAA3E9.6030409@pengutronix.de> <536c077e2e8b4dfabb4c07f696753a3c@BN1PR03MB220.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Oog6rVFJUWKeGodUIIFlfx4wbojGPNpaL"
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "bhupesh.sharma@freescale.com" <bhupesh.sharma@freescale.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60375 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756638AbaFYLIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 07:08:02 -0400
In-Reply-To: <536c077e2e8b4dfabb4c07f696753a3c@BN1PR03MB220.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Oog6rVFJUWKeGodUIIFlfx4wbojGPNpaL
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/25/2014 01:01 PM, bhupesh.sharma@freescale.com wrote:
>> What about function pointers in the priv? So that flexcan_read() becom=
es
>> priv->read().

> That's what I propose (similar to what I did for C_CAN driver for 16-bi=
t and 32-bit
> reg interfaces using platform data):

Yes...but...

> bool module_is_be =3D false;

=2E..module_is_be is not that simple, on PPC true must be the default to
be compatible with existing dts.

> module_is_be =3D get-endianess-from-DT-node;
>=20
> priv->read() =3D module_is_be ? flexcan_read_be : flexcan_read_le;

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Oog6rVFJUWKeGodUIIFlfx4wbojGPNpaL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOqrYQACgkQjTAFq1RaXHP31QCghMsOlQI6Pk41LB2pO4zGK/Yv
HAcAnjyDCBq8hzXozOdX5fAW5eAYQZB0
=VTZc
-----END PGP SIGNATURE-----

--Oog6rVFJUWKeGodUIIFlfx4wbojGPNpaL--
