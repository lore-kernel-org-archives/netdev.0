From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 01/11] net: phy: Add rockchip phy driver support
Date: Sat, 24 Jun 2017 04:19:10 +0200
Message-ID: <20170624021910.GB4875@lunn.ch>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
 <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1498192929-7519-2-git-send-email-david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2017 at 12:41:59PM +0800, David Wu wrote:
> Support internal ephy currently.
> 
> Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
>  drivers/net/phy/Kconfig    |  4 ++
>  drivers/net/phy/Makefile   |  1 +
>  drivers/net/phy/rockchip.c | 94 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 99 insertions(+)
>  create mode 100644 drivers/net/phy/rockchip.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index c360dd6..86010d4 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -350,6 +350,10 @@ config XILINX_GMII2RGMII
>           the Reduced Gigabit Media Independent Interface(RGMII) between
>           Ethernet physical media devices and the Gigabit Ethernet controller.
>  
> +config ROCKCHIP_MAC_PHY

This is a bit of an odd name, having both MAC and PHY in it. Are there
any other RockChip PHYs? Any external PHYS? Are they register
incompatible with the internal PHY?  Is it even RockChip IP? Or has it
been licensed from somebody else?

I would more likely just call it ROCKCHIP_PHY.

  Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
