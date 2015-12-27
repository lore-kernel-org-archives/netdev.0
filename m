From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/4] net: phy: at803x: Don't set gbit features for the
 AR8030 phy
Date: Sat, 26 Dec 2015 19:24:55 -0800
Message-ID: <567F5A07.1000407@gmail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
 <1451089622-14957-2-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: slash.tmp@free.fr
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33778 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444AbbL0DY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2015 22:24:58 -0500
Received: by mail-oi0-f51.google.com with SMTP id y66so160976133oig.0
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2015 19:24:58 -0800 (PST)
In-Reply-To: <1451089622-14957-2-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/12/2015 16:26, Martin Blumenstingl a =C3=A9crit :
> The 8030 is only a "RMII Fast Ethernet PHY", thus it must not have th=
e
> SUPPORTED_1000* bits set.
>=20
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.co=
m>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/at803x.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 2d020a3..f566b6e 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -325,7 +325,7 @@ static struct phy_driver at803x_driver[] =3D {
>  	.get_wol		=3D at803x_get_wol,
>  	.suspend		=3D at803x_suspend,
>  	.resume			=3D at803x_resume,
> -	.features		=3D PHY_GBIT_FEATURES,
> +	.features		=3D PHY_BASIC_FEATURES,
>  	.flags			=3D PHY_HAS_INTERRUPT,
>  	.config_aneg		=3D genphy_config_aneg,
>  	.read_status		=3D genphy_read_status,
>=20


--=20
=46lorian
