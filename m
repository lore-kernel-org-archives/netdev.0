From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH v3 3/5] arm64: dts: rockchip: add the gmac power domain on
 rk3399
Date: Thu, 01 Sep 2016 13:41:42 +0200
Message-ID: <2409903.3qiu7FpA8p@diego>
References: <1472686132-27827-1-git-send-email-wxt@rock-chips.com>
 <1472686132-27827-4-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Huang Tao <huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Elaine Zhang <zhangqing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
 Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
 Shunqian Zheng <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, Jianqun Xu <jay.xu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472686132-27827-4-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Caesar,

Am Donnerstag, 1. September 2016, 07:28:50 schrieb Caesar Wang:
> This patch supports the gmac pd to save power consumption.
> Even though some boards not need Ethernet support, the driver
> core can also take care of powering up the pd before probe.
> 
> Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>

who is the author of this patch? Roger or you? Because we should either drop 
Roger's Signed-off or fix the authorship to list him.


Heiko

> ---
> 
> Changes in v3:
> - leave into two patches based on patchv2, and fix nits and commit, as
>   comment on https://patchwork.kernel.org/patch/9306339/
> 
> Changes in v2:
> - Fixes the order, ss Heiko commnets on
>   https://patchwork.kernel.org/patch/9305991/
> 
>  arch/arm64/boot/dts/rockchip/rk3399.dtsi | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> b/arch/arm64/boot/dts/rockchip/rk3399.dtsi index 32aebc8..2ab233f 100644
> --- a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> +++ b/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> @@ -611,6 +611,11 @@
>  		status = "disabled";
>  	};
> 
> +	qos_gmac: qos@ffa5c000 {
> +		compatible = "syscon";
> +		reg = <0x0 0xffa5c000 0x0 0x20>;
> +	};
> +
>  	qos_hdcp: qos@ffa90000 {
>  		compatible = "syscon";
>  		reg = <0x0 0xffa90000 0x0 0x20>;
> @@ -739,6 +744,11 @@
>  			};
> 
>  			/* These power domains are grouped by VD_LOGIC */
> +			pd_gmac@RK3399_PD_GMAC {
> +				reg = <RK3399_PD_GMAC>;
> +				clocks = <&cru ACLK_GMAC>;
> +				pm_qos = <&qos_gmac>;
> +			};
>  			pd_vio@RK3399_PD_VIO {
>  				reg = <RK3399_PD_VIO>;
>  				#address-cells = <1>;
