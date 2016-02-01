From: Shawn Guo <shawnguo@kernel.org>
Subject: Re: [PATCH net-next 39/40] ARM: dts: imx6qdl-nitrogen6x: add phy
 interrupt to eliminate polling
Date: Mon, 1 Feb 2016 22:03:01 +0800
Message-ID: <20160201140301.GK10671@tiger>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
 <1454016364-30985-40-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:57876 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932325AbcBAODZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 09:03:25 -0500
Content-Disposition: inline
In-Reply-To: <1454016364-30985-40-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 02:26:03PM -0700, Troy Kisky wrote:
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi b/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
> index caeed56..1d42331 100644
> --- a/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
> +++ b/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
> @@ -288,6 +288,15 @@
>  	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
>  			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
>  	status = "okay";
> +	phy-handle = <&ethphy>;

Have a new line between properties and sub-node.

> +	mdio {
> +		#address-cells = <0>;
> +		#size-cells = <1>;

Ditto

Shawn

> +		ethphy: ethernet-phy@6 {
> +			reg = <6>;
> +			interrupts-extended = <&gpio1 28 IRQ_TYPE_LEVEL_LOW>;
> +		};
> +	};
>  };
>  
>  &hdmi {
> @@ -409,6 +418,8 @@
>  				/* Phy reset */
>  				MX6QDL_PAD_ENET_RXD0__GPIO1_IO27	0x000b0
>  				MX6QDL_PAD_GPIO_6__ENET_IRQ		0x000b1
> +				/* ethernet phy interrupt */
> +				MX6QDL_PAD_ENET_TX_EN__GPIO1_IO28	0x1b0b0
>  			>;
>  		};
>  
> -- 
> 2.5.0
> 
> 
