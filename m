From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: phy: vitesse: advertise PAUSE frame capabilities
 on Vitesse PHY drivers
Date: Sat, 22 Feb 2014 13:38:56 +0000
Message-ID: <1393076336.15717.97.camel@deadeye.wl.decadent.org.uk>
References: <1392999584-29836-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8XH4rd6ezn4LmkAUvd7A"
Cc: netdev@vger.kernel.org, madalin.bucur@freescale.com,
	shaohui.xie@freescale.com, shruti@freescale.com
To: cristian.bercaru@freescale.com,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56977 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750942AbaBVNjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 08:39:06 -0500
In-Reply-To: <1392999584-29836-1-git-send-email-cristian.bercaru@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8XH4rd6ezn4LmkAUvd7A
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-02-21 at 18:19 +0200, cristian.bercaru@freescale.com wrote:
> From: Cristian Bercaru <cristian.bercaru@freescale.com>
>=20
> Enable the advertisment of symmetric and asymmetric PAUSE frame
> capabilities on all Vitesse PHY drivers.

I don't think this makes sense.  So far as I know, pause frame support
depends only on the MAC, not the PHY.

I realise there are already other PHY drivers setting these flags, but
why should they be added to every PHY driver individually when any
autonegotiating PHY can advertise pause capability?

Ben.

> Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
> ---
>  drivers/net/phy/vitesse.c | 21 ++++++++++++++-------
>  1 file changed, 14 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
> index 14372c6..3124b31 100644
> --- a/drivers/net/phy/vitesse.c
> +++ b/drivers/net/phy/vitesse.c
> @@ -227,7 +227,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
>  	.phy_id         =3D PHY_ID_VSC8234,
>  	.name           =3D "Vitesse VSC8234",
>  	.phy_id_mask    =3D 0x000ffff0,
> -	.features       =3D PHY_GBIT_FEATURES,
> +	.features       =3D PHY_GBIT_FEATURES |
> +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>  	.flags          =3D PHY_HAS_INTERRUPT,
>  	.config_init    =3D &vsc824x_config_init,
>  	.config_aneg    =3D &vsc82x4_config_aneg,
> @@ -239,7 +240,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
>  	.phy_id		=3D PHY_ID_VSC8244,
>  	.name		=3D "Vitesse VSC8244",
>  	.phy_id_mask	=3D 0x000fffc0,
> -	.features	=3D PHY_GBIT_FEATURES,
> +	.features       =3D PHY_GBIT_FEATURES |
> +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>  	.flags		=3D PHY_HAS_INTERRUPT,
>  	.config_init	=3D &vsc824x_config_init,
>  	.config_aneg	=3D &vsc82x4_config_aneg,
> @@ -251,7 +253,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
>  	.phy_id		=3D PHY_ID_VSC8514,
>  	.name		=3D "Vitesse VSC8514",
>  	.phy_id_mask	=3D 0x000ffff0,
> -	.features	=3D PHY_GBIT_FEATURES,
> +	.features       =3D PHY_GBIT_FEATURES |
> +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>  	.flags		=3D PHY_HAS_INTERRUPT,
>  	.config_init	=3D &vsc824x_config_init,
>  	.config_aneg	=3D &vsc82x4_config_aneg,
> @@ -263,7 +266,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
>  	.phy_id         =3D PHY_ID_VSC8574,
>  	.name           =3D "Vitesse VSC8574",
>  	.phy_id_mask    =3D 0x000ffff0,
> -	.features       =3D PHY_GBIT_FEATURES,
> +	.features       =3D PHY_GBIT_FEATURES |
> +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>  	.flags          =3D PHY_HAS_INTERRUPT,
>  	.config_init    =3D &vsc824x_config_init,
>  	.config_aneg    =3D &vsc82x4_config_aneg,
> @@ -275,7 +279,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
>  	.phy_id         =3D PHY_ID_VSC8662,
>  	.name           =3D "Vitesse VSC8662",
>  	.phy_id_mask    =3D 0x000ffff0,
> -	.features       =3D PHY_GBIT_FEATURES,
> +	.features       =3D PHY_GBIT_FEATURES |
> +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>  	.flags          =3D PHY_HAS_INTERRUPT,
>  	.config_init    =3D &vsc824x_config_init,
>  	.config_aneg    =3D &vsc82x4_config_aneg,
> @@ -288,7 +293,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
>  	.phy_id		=3D PHY_ID_VSC8221,
>  	.phy_id_mask	=3D 0x000ffff0,
>  	.name		=3D "Vitesse VSC8221",
> -	.features	=3D PHY_GBIT_FEATURES,
> +	.features       =3D PHY_GBIT_FEATURES |
> +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>  	.flags		=3D PHY_HAS_INTERRUPT,
>  	.config_init	=3D &vsc8221_config_init,
>  	.config_aneg	=3D &genphy_config_aneg,
> @@ -301,7 +307,8 @@ static struct phy_driver vsc82xx_driver[] =3D {
>  	.phy_id		=3D PHY_ID_VSC8211,
>  	.phy_id_mask	=3D 0x000ffff0,
>  	.name		=3D "Vitesse VSC8211",
> -	.features	=3D PHY_GBIT_FEATURES,
> +	.features       =3D PHY_GBIT_FEATURES |
> +			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>  	.flags		=3D PHY_HAS_INTERRUPT,
>  	.config_init	=3D &vsc8221_config_init,
>  	.config_aneg	=3D &genphy_config_aneg,

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-8XH4rd6ezn4LmkAUvd7A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwiocee/yOyVhhEJAQoU4RAAoSCwgoPXQhB/nRdqSjSJ4nQD7J/r3g2F
ZkWdn7+eYfqfqUZUZsGXyi223caqgqlpiRKlyYxrXoGJgAzRjNHeLgOjTjXCEAYa
noGQENTBaULg/Sm31L2QNAMK4OHtBZSeu7ik5O9pP4Gr1NCKaH1nLozS4aA1Zfss
UoWOntHS+/Vf2IFyhzwjimH7/VOOwNWDfqOLBRO7CceUBCFzquu6JzhFXYfCIOoN
tXKQMxRH/Pvu0E+4gI9db5MTDGJ5NVAVah0ruM74aJvkJ6viuLBx/jMcKvNXnsq6
6h7Zwx+NRNisRwrGSbuTNJ2jyR76HpFEu/78Pf24IGxl7mo9zLrHjPP4DayNN+lZ
5LI55k5zeVJfd1mOL2lk5fn6Eo47zTwUFL95Fz1E7orCS6NJmPaNr7UG7u5nfIor
+Rk54MxEVERjdPnw08X8K2PxiS4hQWiPxPJYz6dc8Z4DdN64bZTrgwMKjT4FUWmp
m0gOpJ3NgFgZ3dFte3YJTtW3a810q8vgUyJsHNkZd5qJSyunu5zOWyZLC2d68X11
ciqBIVUcuLiC2v9f0ixxLNls3wTqgQ4kIhxo+pVtrPN5+RDUHFvAmk7lQp/nITO5
1LtNUDCJrI85xoGwMhpTqiBZkgKpb3A/VOqmYrpgMizWHOWKcWeOe65ui1xKoZGq
czzVC4QbMB0=
=EXiU
-----END PGP SIGNATURE-----

--=-8XH4rd6ezn4LmkAUvd7A--
