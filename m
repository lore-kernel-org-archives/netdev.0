From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/5] dsa: Microchip KSZ switches SPI devicetree
 configuration
Date: Sat, 6 May 2017 05:54:15 +0200
Message-ID: <20170506035415.GC14749@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A5C00B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51876 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750899AbdEFDyS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 23:54:18 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A5C00B@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 05, 2017 at 11:18:05PM +0000, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <Woojung.Huh@microchip.com>
> 
> A sample SPI configuration for Microchip KSZ switches.
> 
> Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
> ---
>  Documentation/devicetree/bindings/net/dsa/ksz.txt | 73 +++++++++++++++++++++++
>  1 file changed, 73 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/ksz.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/ksz.txt b/Documentation/devicetree/bindings/net/dsa/ksz.txt
> new file mode 100644
> index 0000000..9cca7d4
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/ksz.txt
> @@ -0,0 +1,73 @@
> +Microchip KSZ Series Ethernet switches
> +==================================
> +
> +Required properties:
> +
> +- compatible: For external switch chips, compatible string must be exactly one
> +  of: "microchip,ksz9477"
> +
> +See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional
> +required and optional properties.
> +
> +Examples:
> +
> +Ethernet switch connected via SPI to the host, CPU port wired to eth0:
> +
> +		eth0: ethernet@10001000 {
> +			fixed-link {
> +				reg = <7>
> +				speed = <1000>;
> +				duplex-full;
> +			};
> +		};
> +

..

> +				port@5 {
> +					reg = <5>;
> +					label = "cpu";
> +					ethernet = <&macb0>;

I think this should be ethernet = <&eth0>;

  Andrew
