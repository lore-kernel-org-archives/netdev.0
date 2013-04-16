From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/5] can: mcp251x: Remove unneeded PM_OPS definitions
Date: Tue, 16 Apr 2013 21:42:13 +0200
Message-ID: <516DA995.8010301@pengutronix.de>
References: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2HNGSCJWLQMUKUUTLVUDG"
Cc: davem@davemloft.net, netdev@vger.kernel.org, joe@perches.com
To: Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56060 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935589Ab3DPTmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:42:23 -0400
In-Reply-To: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2HNGSCJWLQMUKUUTLVUDG
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 04/16/2013 09:28 PM, Fabio Estevam wrote:
> SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so the=
re is no
> need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cas=
es.
>=20
> Remove the unneeded definitions.
>=20
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

David, are you directly taking the whole series? If not, this patch will
go through the linux-can tree.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2HNGSCJWLQMUKUUTLVUDG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFtqZkACgkQjTAFq1RaXHOAawCghW+mZo0I5Pt9FkmA1aoAlIhk
YTsAn0zEvddA23kHtgP0A/H9uC8pHoBq
=SgvS
-----END PGP SIGNATURE-----

------enig2HNGSCJWLQMUKUUTLVUDG--
