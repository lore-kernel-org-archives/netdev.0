From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] dts: Add a binding for Synopsys emac max-mtu
Date: Fri, 10 Jan 2014 16:31:27 -0800
Message-ID: <CAGVrzcZcnKyP1HVZMWDTAC-+Z7oWiLHqx6SSHAWGO2WVcXGjrA@mail.gmail.com>
References: <1389397669-10929-1-git-send-email-vbridgers2013@gmail.com> <1389397669-10929-3-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	robh+dt@kernel.org, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	dinguyen@altera.com, Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:62555 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbaAKAcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 19:32:11 -0500
In-Reply-To: <1389397669-10929-3-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/10 Vince Bridgers <vbridgers2013@gmail.com>:
> This change adds a parameter for the Synopsys 10/100/1000
> stmmac Ethernet driver to configure the maximum MTU supported
> by the EMAC instance. Synopsys allows the FIFO sizes to
> be configured when the cores are built for a particular
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
> index eba0e5e..7db314e 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -30,6 +30,10 @@ Required properties:
>
>  Optional properties:
>  - mac-address: 6 bytes, mac address
> +- snps,max-mtu:                Maximum MTU permitted. This parameter is useful since
> +                       different implementations of the Synopsys MAC may have
> +                       different FIFO sizes depending on the selections
> +                       made in Synopsys Core Consultant.

ePAPR v1.1 defines "max-frame-size" as being "Specifies maximum packet
length in bytes that the physical interface can send and receive.", I
would recommend you use that instead of this custom property.

>
>  Examples:
>
> @@ -40,5 +44,6 @@ Examples:
>                 interrupts = <24 23>;
>                 interrupt-names = "macirq", "eth_wake_irq";
>                 mac-address = [000000000000]; /* Filled in by U-Boot */
> +               snps,max-mtu = <3800>;
>                 phy-mode = "gmii";
>         };
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
