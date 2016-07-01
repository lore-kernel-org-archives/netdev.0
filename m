From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 6/7] dt-bindings: net: bgmac: add bindings documentation
 for bgmac
Date: Thu, 30 Jun 2016 21:56:19 -0500
Message-ID: <20160701025619.GA4906@rob-hp-laptop>
References: <1467327554-22074-1-git-send-email-jon.mason@broadcom.com>
 <1467327554-22074-7-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zajec5@gmail.com, davem@davemloft.net, f.fainelli@gmail.com,
	hauke@hauke-m.de, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1467327554-22074-7-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 30, 2016 at 06:59:13PM -0400, Jon Mason wrote:
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>  .../devicetree/bindings/net/brcm,bgmac-nsp.txt     | 24 ++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt b/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
> new file mode 100644
> index 0000000..022946c
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
> @@ -0,0 +1,24 @@
> +Broadcom GMAC Ethernet Controller Device Tree Bindings
> +-------------------------------------------------------------
> +
> +Required properties:
> + - compatible:	"brcm,bgmac-nsp"

Usually we do <soc>-<block> order.

> + - reg:		Address and length of the GMAC registers,
> +		Address and length of the GMAC IDM registers
> + - reg-names:	Names of the registers.  Must have both "gmac_base" and
> +		"idm_base"
> + - interrupts:	Interrupt number
> +
> +Optional properties:
> +- mac-address:	See ethernet.txt file in the same directory
> +
> +Examples:
> +
> +gmac0: ethernet@18022000 {
> +	compatible = "brcm,bgmac-nsp";
> +	reg = <0x18022000 0x1000>,
> +	      <0x18110000 0x1000>;
> +	reg-names = "gmac_base", "idm_base";
> +	interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
> +	status = "disabled";
> +};
> -- 
> 1.9.1
> 
