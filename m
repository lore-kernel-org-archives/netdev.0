From: Shawn Guo <shawnguo@kernel.org>
Subject: Re: [PATCH net-next 40/40] ARM: dts: imx6qdl-nitrogen6_max: add phy
 interrupt to eliminate polling
Date: Mon, 1 Feb 2016 22:04:20 +0800
Message-ID: <20160201140420.GL10671@tiger>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
 <1454016364-30985-41-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:57972 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932325AbcBAOEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 09:04:41 -0500
Content-Disposition: inline
In-Reply-To: <1454016364-30985-41-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 02:26:04PM -0700, Troy Kisky wrote:
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi b/arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi
> index a35d54f..771f650 100644
> --- a/arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi
> +++ b/arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi
> @@ -386,6 +386,15 @@
>  	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
>  			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
>  	status = "okay";
> +	phy-handle = <&ethphy>;

Please keep 'status' at the bottom of the property list.

Shawn

> +	mdio {
> +		#address-cells = <0>;
> +		#size-cells = <1>;
> +		ethphy: ethernet-phy@6 {
> +			reg = <6>;
> +			interrupts-extended = <&gpio1 28 IRQ_TYPE_LEVEL_LOW>;
> +		};
> +	};
>  };
>  
>  &hdmi {
> -- 
> 2.5.0
> 
> 
