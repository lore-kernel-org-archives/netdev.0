From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 1/1] arm: dts: imx6 fix fec ptp clock slow 10 time
Date: Tue, 5 Feb 2013 15:45:53 +0800
Message-ID: <20130205074551.GC16787@S2101-09.ap.freescale.net>
References: <1360045266-4518-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <lznuaa@gmail.com>, <linux-arm-kernel@lists.infradead.org>,
	<B38611@freescale.com>, <s.hauer@pengutronix.de>,
	<netdev@vger.kernel.org>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:19332
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751838Ab3BEHpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 02:45:41 -0500
Content-Disposition: inline
In-Reply-To: <1360045266-4518-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2013 at 02:21:06PM +0800, Frank Li wrote:
> ptp should use enet_ref instead of pll6_enet
> pll6_enet is fixed 500Mhz.
> There are divider between enet_ref and pll6_enet
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied as a fix for 3.8.

Shawn

> ---
>  arch/arm/boot/dts/imx6q.dtsi |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/imx6q.dtsi b/arch/arm/boot/dts/imx6q.dtsi
> index d6265ca..ff1205e 100644
> --- a/arch/arm/boot/dts/imx6q.dtsi
> +++ b/arch/arm/boot/dts/imx6q.dtsi
> @@ -866,7 +866,7 @@
>  				compatible = "fsl,imx6q-fec";
>  				reg = <0x02188000 0x4000>;
>  				interrupts = <0 118 0x04 0 119 0x04>;
> -				clocks = <&clks 117>, <&clks 117>, <&clks 177>;
> +				clocks = <&clks 117>, <&clks 117>, <&clks 190>;
>  				clock-names = "ipg", "ahb", "ptp";
>  				status = "disabled";
>  			};
> -- 
> 1.7.1
> 
> 
