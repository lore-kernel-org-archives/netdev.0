From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] Add LAN9352 Ethernet Driver
Date: Wed, 10 Feb 2016 19:13:50 +0100
Message-ID: <20160210181350.GI9492@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF199@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, corbet@lwn.net
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53906 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752082AbcBJSNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 13:13:55 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EF199@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 09, 2016 at 08:40:30PM +0000, Bryan.Whitehead@microchip.com wrote:
> This is the initial submission of an ethernet driver for
> the Microchip LAN9352. 
> 
> The LAN9352 is a 2-Port 10/100 Managed Ethernet Switch 
> with 16-Bit Non-PCI CPU Interface.
> 
> While the LAN9352 is a Managed Ethernet Switch, this driver
> only supports a simple ethernet controller interface.
> 
> Signed-off-by: Bryan Whitehead <Bryan.Whitehead@microchip.com>
> ---
>  Documentation/devicetree/bindings/net/mchp9352.txt |   31 +
>  MAINTAINERS                                        |    9 +
>  drivers/net/ethernet/microchip/Kconfig             |   23 +-
>  drivers/net/ethernet/microchip/Makefile            |    1 +
>  drivers/net/ethernet/microchip/mchp9352.c          | 2593 ++++++++++++++++++++
>  drivers/net/ethernet/microchip/mchp9352.h          |  448 ++++
>  6 files changed, 3104 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/devicetree/bindings/net/mchp9352.txt
>  create mode 100644 drivers/net/ethernet/microchip/mchp9352.c
>  create mode 100644 drivers/net/ethernet/microchip/mchp9352.h
> 
> diff --git a/Documentation/devicetree/bindings/net/mchp9352.txt b/Documentation/devicetree/bindings/net/mchp9352.txt
> new file mode 100644
> index 0000000..5b22e73
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mchp9352.txt
> @@ -0,0 +1,31 @@
> +* Microchip LAN9352 Controller
> +
> +Required properties:
> +- compatible : Should be "microchip,lan9352"
> +- reg : Address and length of the io space for Microchip LAN
> +- interrupts : Should contain Microchip LAN interrupt line
> +- interrupt-parent : Should be the phandle for the interrupt controller
> +  that services interrupts for this device
> +- phy-mode : See ethernet.txt file in the same directory

Hi Bryan

You say this is a 2 port switch. So which port does this phy-mode
apply to? Should this be a per port property?

      Andrew
