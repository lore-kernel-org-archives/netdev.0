From: Dinh Nguyen <dinguyen@altera.com>
Subject: Re: [PATCH net-next v2 1/2] dts: Add a binding for Synopsys emac
 max-frame-size
Date: Tue, 14 Jan 2014 09:57:36 -0600
Message-ID: <1389715056.10673.9.camel@linux-builds1>
References: <1389710409-14106-1-git-send-email-vbridgers2013@gmail.com>
	 <1389710409-14106-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<peppe.cavallaro@st.com>, <robh+dt@kernel.org>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<rayagond@vayavyalabs.com>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:10550
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751458AbaANP7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 10:59:35 -0500
In-Reply-To: <1389710409-14106-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-14 at 08:40 -0600, Vince Bridgers wrote:
> This change adds a parameter for the Synopsys 10/100/1000
> stmmac Ethernet driver to configure the maximum frame
> size supported by the EMAC driver. Synopsys allows the FIFO
> sizes to be configured when the cores are built for a particular
> device, but do not provide a way for the driver to read
> information from the device about the maximum MTU size
> supported as limited by the device's FIFO size.
> 
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index eba0e5e..26a0ba9 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -30,6 +30,10 @@ Required properties:
>  
>  Optional properties:
>  - mac-address: 6 bytes, mac address
> +- snps,max-frame-size:	Maximum frame size permitted. This parameter is useful 

I don't think max-frame-size should be a snps-only binding.

Dinh
> +			since different implementations of the Synopsys MAC may 
> +			have different FIFO sizes depending on the selections
> +			made in Synopsys Core Consultant.


>  
>  Examples:
>  
> @@ -40,5 +44,6 @@ Examples:
>  		interrupts = <24 23>;
>  		interrupt-names = "macirq", "eth_wake_irq";
>  		mac-address = [000000000000]; /* Filled in by U-Boot */
> +		snps,max-frame-size = <3800>;
>  		phy-mode = "gmii";
>  	};
