From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH v2 2/5] net: phy: Add Meson GXL Internal PHY driver
Date: Mon, 31 Oct 2016 20:05:58 +0100
Message-ID: <20161031190558.GK9441@lunn.ch>
References: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
 <1477932987-27871-3-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, khilman@baylibre.com, carlo@caione.org,
        netdev@vger.kernel.org, linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477932987-27871-3-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 31, 2016 at 05:56:24PM +0100, Neil Armstrong wrote:
> Add driver for the Internal RMII PHY found in the Amlogic Meson GXL SoCs.
> 
> This PHY seems to only implement some standard registers and need some
> workarounds to provide autoneg values from vendor registers.
> 
> Some magic values are currently used to configure the PHY, and this a
> temporary setup until clarification about these registers names and
> registers fields are provided by Amlogic.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  drivers/net/phy/Kconfig     |  5 +++
>  drivers/net/phy/Makefile    |  1 +
>  drivers/net/phy/meson-gxl.c | 81 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 87 insertions(+)
>  create mode 100644 drivers/net/phy/meson-gxl.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 2651c8d..09342b6 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -226,6 +226,11 @@ config DP83867_PHY
>  	---help---
>  	  Currently supports the DP83867 PHY.
>  
> +config MESON_GXL_PHY
> +	tristate "Amlogic Meson GXL Internal PHY"
> +	---help---
> +	  Currently has a driver for the Amlogic Meson GXL Internal PHY
> +

Hi Neil

Please keep them in alphabetic order. This goes after Marvell.

>  config FIXED_PHY
>  	tristate "MDIO Bus/PHY emulation with fixed speed/link PHYs"
>  	depends on PHYLIB
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index e58667d..1511b3e 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -44,6 +44,7 @@ obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
>  obj-$(CONFIG_MICREL_KS8995MA)	+= spi_ks8995.o
>  obj-$(CONFIG_MICREL_PHY)	+= micrel.o
>  obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
> +obj-$(CONFIG_MESON_GXL_PHY)	+= meson-gxl.o
>  obj-$(CONFIG_MICROSEMI_PHY)	+= mscc.o

Again, alphabetic order.

       Andrew
