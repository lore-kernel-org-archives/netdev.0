From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4 1/6] net: stmmac: dwmac-rk: add rk3366 & rk3399
 specific data
Date: Mon, 12 Sep 2016 08:28:50 -0500
Message-ID: <20160912132850.GA24241@rob-hp-laptop>
References: <1472752204-8924-1-git-send-email-wxt@rock-chips.com>
 <1472752204-8924-2-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1472752204-8924-2-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 02, 2016 at 01:49:59AM +0800, Caesar Wang wrote:
> From: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> 
> Add constants and callback functions for the dwmac on rk3228/rk3229 socs.
> As can be seen, the base structure is the same, only registers and the
> bits in them moved slightly.
> 
> Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> Reviewed-by: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
> 
> ---
> 
> Changes in v4:
> - Fixes from the original patch on https://patchwork.kernel.org/patch/9274557/
> 
> Changes in v3: None
> Changes in v2: None
> 
>  .../devicetree/bindings/net/rockchip-dwmac.txt     |   8 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 226 +++++++++++++++++++++
>  2 files changed, 232 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> index cccd945..95383c5 100644
> --- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> @@ -3,8 +3,12 @@ Rockchip SoC RK3288 10/100/1000 Ethernet driver(GMAC)
>  The device node has following properties.
>  
>  Required properties:
> - - compatible: Can be one of "rockchip,rk3228-gmac", "rockchip,rk3288-gmac",
> -                             "rockchip,rk3368-gmac"
> + - compatible: should be "rockchip,<name>-gamc"

s/gamc/gmac/

Please send a follow-up patch to fix.

> +   "rockchip,rk3228-gmac": found on RK322x SoCs
> +   "rockchip,rk3288-gmac": found on RK3288 SoCs
> +   "rockchip,rk3366-gmac": found on RK3366 SoCs
> +   "rockchip,rk3368-gmac": found on RK3368 SoCs
> +   "rockchip,rk3399-gmac": found on RK3399 SoCs
>   - reg: addresses and length of the register sets for the device.
>   - interrupts: Should contain the GMAC interrupts.
>   - interrupt-names: Should contain the interrupt names "macirq".
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
