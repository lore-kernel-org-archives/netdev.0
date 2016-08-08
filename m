From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 1/3] net: stmmac: dwmac-rk: add rk3366 & rk3399-specific data
Date: Mon, 08 Aug 2016 22:35:29 +0200
Message-ID: <3635712.eAtD6Fn9AW@diego>
References: <1467802291-6487-1-git-send-email-roger.chen@rock-chips.com> <1467802291-6487-2-git-send-email-roger.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467802291-6487-2-git-send-email-roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Roger,

Am Mittwoch, 6. Juli 2016, 18:51:29 schrieb Roger Chen:
> Add constants and callback functions for the dwmac on rk3368 socs.
> As can be seen, the base structure is the same, only registers and
> the bits in them moved slightly.
> 
> Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
>  .../devicetree/bindings/net/rockchip-dwmac.txt     |   3 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 226
> +++++++++++++++++++++ 2 files changed, 228 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt index
> 93eac7c..8c066e6 100644
> --- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> @@ -3,7 +3,8 @@ Rockchip SoC RK3288 10/100/1000 Ethernet driver(GMAC)
>  The device node has following properties.
> 
>  Required properties:
> - - compatible: Can be one of "rockchip,rk3288-gmac", "rockchip,rk3368-gmac"
> + - compatible: Can be one of "rockchip,rk3288-gmac",
> "rockchip,rk3366-gmac", +                            
> "rockchip,rk3368-gmac", "rockchip,rk3399-gmac" - reg: addresses and length
> of the register sets for the device. - interrupts: Should contain the GMAC
> interrupts.
>   - interrupt-names: Should contain the interrupt names "macirq".

this doesn't apply against 4.8-rc1 anymore, can you please rebase and resend 
the series?


Thanks
Heiko
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
