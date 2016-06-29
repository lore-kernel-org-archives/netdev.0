From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 6/7] dt-bindings: net: bgmac: add bindings documentation for
 bgmac
Date: Wed, 29 Jun 2016 11:37:55 -0700
Message-ID: <57741583.6020904@gmail.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-7-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35235 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbcF2Sh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 14:37:58 -0400
In-Reply-To: <1467142484-11161-7-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2016 12:34 PM, Jon Mason wrote:
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>  .../devicetree/bindings/net/brcm,bgmac-enet.txt     | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt b/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
> new file mode 100644
> index 0000000..efd36d5
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
> @@ -0,0 +1,21 @@
> +Broadcom GMAC Ethernet Controller Device Tree Bindings
> +-------------------------------------------------------------
> +
> +Required properties:
> + - compatible:	"brcm,bgmac-enet"

You might want something a bit more explicit like "brcm,bgmac-nsp" for
instance and also define a compatible string for the Northstar family maybe?

> + - reg:		Address and length of the GMAC registers,
> +		Address and length of the GMAC IDM registers
> + - interrupts:	Interrupt number
> +
> +Optional properties:
> +- mac-address:	mac address to be assigned to the device
> +
> +Examples:
> +
> +gmac0: enet@18022000 {
> +	compatible = "brcm,bgmac-enet";
> +	reg = <0x18022000 0x1000>,
> +	      <0x18110000 0x1000>;
> +	interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
> +	status = "disabled";
> +};
> 


-- 
Florian
