From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83867: Fix warning check for setting the
 internal delay
Date: Tue, 21 Jul 2015 10:14:12 -0700
Message-ID: <55AE7DE4.1080404@gmail.com>
References: <1437498405-1723-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcb314@hotmail.com
To: Dan Murphy <dmurphy@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33340 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932289AbbGURQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:16:07 -0400
Received: by padck2 with SMTP id ck2so122935883pad.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 10:16:07 -0700 (PDT)
In-Reply-To: <1437498405-1723-1-git-send-email-dmurphy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/07/15 10:06, Dan Murphy wrote:
> Fix warning: logical =E2=80=98or=E2=80=99 of collectively exhaustive =
tests is always true
>=20
> Change the internal delay check from an 'or' condition to an 'and'
> condition.
>=20
> Reported-by: David Binderman <dcb314@hotmail.com>
> Signed-off-by: Dan Murphy <dmurphy@ti.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/dp83867.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
> index c7a12e2..8a3bf54 100644
> --- a/drivers/net/phy/dp83867.c
> +++ b/drivers/net/phy/dp83867.c
> @@ -164,7 +164,7 @@ static int dp83867_config_init(struct phy_device =
*phydev)
>  			return ret;
>  	}
> =20
> -	if ((phydev->interface >=3D PHY_INTERFACE_MODE_RGMII_ID) ||
> +	if ((phydev->interface >=3D PHY_INTERFACE_MODE_RGMII_ID) &&
>  	    (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
>  		val =3D phy_read_mmd_indirect(phydev, DP83867_RGMIICTL,
>  					    DP83867_DEVADDR, phydev->addr);
>=20


--=20
=46lorian
