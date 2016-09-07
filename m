From: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH v4 5/6] arm64: dts: rockchip: add the gmac needed node for rk3399
Date: Wed, 07 Sep 2016 20:12:23 +0200
Message-ID: <2189752.joCqtnIJ7y@phil>
References: <1472752204-8924-1-git-send-email-wxt@rock-chips.com> <1472752204-8924-6-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Huang Tao <huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Elaine Zhang <zhangqing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Jianqun Xu <jay.xu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Shunqian Zheng <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel@vger.
To: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472752204-8924-6-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, 2. September 2016, 01:50:03 CEST schrieb Caesar Wang:
> From: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> 
> The RK3399 GMAC Ethernet Controller provides a complete Ethernet interface
> from processor to a Reduced Media Independent Interface (RMII) and Reduced
> Gigabit Media Independent Interface (RGMII) compliant Ethernet PHY.
> 
> This patch adds the related needed device information.
> e.g.: interrupts, grf, clocks, pinctrl and so on.
> 
> The full details are in [0].
> 
> [0]:
> Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> 
> Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
> 
> Changes in v4:
> - The Roger had posted patch on https://patchwork.kernel.org/patch/9274561/.
> - re-fixup to original author.
> 
> Changes in v3:
> - generate a patch from https://patchwork.kernel.org/patch/9306339/.
> 
> Changes in v2: None
> 
>  arch/arm64/boot/dts/rockchip/rk3399.dtsi | 80
> ++++++++++++++++++++++++++++++++ 1 file changed, 80 insertions(+)
> 
> diff --git a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> b/arch/arm64/boot/dts/rockchip/rk3399.dtsi index 2ab233f..092bb45 100644
> --- a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> +++ b/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> @@ -200,6 +200,26 @@
>  		};
>  	};
> 
> +	gmac: ethernet@fe300000 {
> +		compatible = "rockchip,rk3399-gmac";
> +		reg = <0x0 0xfe300000 0x0 0x10000>;
> +		interrupts = <GIC_SPI 12 IRQ_TYPE_LEVEL_HIGH>;

applied to my dts64 branch, after making this a
+		interrupts = <GIC_SPI 12 IRQ_TYPE_LEVEL_HIGH 0>;

(due to the 4-cell interrupt change)


Heiko
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
