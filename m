From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: add dependency on HAS_IOMEM to MDIO_BUS_MUX_MMIOREG
Date: Mon, 6 Jul 2015 10:19:39 -0700
Message-ID: <CAGVrzca9p4Sg8H53Oy=dTQmCXYD-1RugrnXQBTz1e7p7gBYL4w@mail.gmail.com>
References: <1436116587-1982-1-git-send-email-robh@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:34344 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbbGFRUU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 13:20:20 -0400
Received: by obbkm3 with SMTP id km3so111439591obb.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 10:20:19 -0700 (PDT)
In-Reply-To: <1436116587-1982-1-git-send-email-robh@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-07-05 10:16 GMT-07:00 Rob Herring <robh@kernel.org>:
> On UML builds, mdio-mux-mmioreg.c fails to compile:
>
> drivers/net/phy/mdio-mux-mmioreg.c:50:3: error: implicit declaration =
of function =E2=80=98ioremap=E2=80=99 [-Werror=3Dimplicit-function-decl=
aration]
> drivers/net/phy/mdio-mux-mmioreg.c:63:3: error: implicit declaration =
of function =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-decl=
aration]
>
> This is due to CONFIG_OF now being user selectable. Add a dependency =
on
> HAS_IOMEM to fix this.
>
> Signed-off-by: Rob Herring <robh@kernel.org>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/phy/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index cf18940..cb86d7a 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -191,7 +191,7 @@ config MDIO_BUS_MUX_GPIO
>
>  config MDIO_BUS_MUX_MMIOREG
>         tristate "Support for MMIO device-controlled MDIO bus multipl=
exers"
> -       depends on OF_MDIO
> +       depends on OF_MDIO && HAS_IOMEM
>         select MDIO_BUS_MUX
>         help
>           This module provides a driver for MDIO bus multiplexers tha=
t
> --
> 2.1.0
>



--=20
=46lorian
