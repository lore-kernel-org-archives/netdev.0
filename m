From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH net v2 4/7] net: cpmac: fix cpmac driver structure
Date: Thu, 10 Jul 2014 08:08:12 -0500
Message-ID: <20140710130812.GD15340@saruman.home>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
 <1404970545-26508-5-git-send-email-varkabhadram@gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fOHHtNG4YXGJ0yqR"
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<linux@rainbow-software.org>, <balbi@ti.com>,
	<george.cherian@ti.com>, <davem@davemloft.net>,
	Varka Bhadram <varkab@cdac.in>
To: <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:54753 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753621AbaGJNJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 09:09:08 -0400
Content-Disposition: inline
In-Reply-To: <1404970545-26508-5-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--fOHHtNG4YXGJ0yqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 10, 2014 at 11:05:42AM +0530, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
>=20
> This patch changes to style of declarattion which follows every driver
>=20
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

Reviewed-by: Felipe Balbi <balbi@ti.com>

> ---
>  drivers/net/ethernet/ti/cpmac.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cp=
mac.c
> index 9faf669..1520c19 100644
> --- a/drivers/net/ethernet/ti/cpmac.c
> +++ b/drivers/net/ethernet/ti/cpmac.c
> @@ -1187,9 +1187,11 @@ static int cpmac_remove(struct platform_device *pd=
ev)
>  }
> =20
>  static struct platform_driver cpmac_driver =3D {
> -	.driver.name =3D "cpmac",
> -	.driver.owner =3D THIS_MODULE,
> -	.probe =3D cpmac_probe,
> +	.driver =3D {
> +		.name 	=3D "cpmac",
> +		.owner 	=3D THIS_MODULE,
> +	},
> +	.probe 	=3D cpmac_probe,
>  	.remove =3D cpmac_remove,
>  };
> =20
> --=20
> 1.7.9.5
>=20

--=20
balbi

--fOHHtNG4YXGJ0yqR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTvpA8AAoJEIaOsuA1yqREp5wP/2N/VPympIoRDmG6tlz73KkO
r4/dkJ61qR3vIz5UDUdL5bq+LlKPe0fav4L0TlSrpvcCYjx8/mHQwkiuq74jv9Qp
afWuquhIS2s0VvBp3Hg/XWtANgsMDfhU76rtHFDUVUWTfT79vweLwrNMBfSAdPe8
fo511ltJzEjhlTpYBDOQNPKP/BCloHpv6PgU24MWg5ofXPb/+BxZPbG7aJLAo5BD
MGo3D7L+h7uJBaQ4HQvQqF3YENSx4pd6hr3cFpIJwW10kzOmYGl+bHJRO3oPdsLl
8P2AcU2CBBTi4qTJO7xuBijYDU3edseMQRDMBzbrS5kmeTFMiwvBQC7dFpHDKFGm
n7h35pS3B6EaDG9at0DrFijoj2lGIkxpN3ksppOEqQT5tMX350xQlG36zOCCTx9v
IAoiihpm57LmyeGbL+2HYnlTc0q7oprnIOP3jY9h/1ETBcv4uFcUvq4SlPIGYuhs
PP+hCuWjNvFHhQbTrnfuw4bgTQ/V0P75bXRUmHCN2Sreajq0Ih/xJkqjtjwuBAGy
jMbvY1W5ORodKEaftu/Ow2NwDUjrJSBoWFOhxhkQAx/QmsKEprSCHWfu7WaWflw+
x9/jpXJMsOoMkQ2jlYXROefheEYoMI9svLTcVD4mj1h3/DO6HQhg0BB2TYjY2nG1
5KJzfi1TWcLx36o1AfaU
=MNz0
-----END PGP SIGNATURE-----

--fOHHtNG4YXGJ0yqR--
