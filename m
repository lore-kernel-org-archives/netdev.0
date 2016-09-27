From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 27 Sep 2016 16:16:33 +0200
Message-ID: <20160927141633.GJ28432@lunn.ch>
References: <1474984075-12312-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        f.fainelli@gmail.com, Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34434 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933232AbcI0OQh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 10:16:37 -0400
Content-Disposition: inline
In-Reply-To: <1474984075-12312-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> index 0000000..7ba3855
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> @@ -0,0 +1,61 @@
> +* Microsemi - vsc8531 Giga bit ethernet phy
> +
> +Required properties:
> +- compatible	: Should contain phy id as "ethernet-phy-idAAAA.BBBB"
> +		  If the phy's identifier is known then the list may contain an entry
> +		  of the form: "ethernet-phy-idAAAA.BBBB" where
> +		  AAAA - The value of the 16 bit Phy Identifier 1 register as
> +			 4 hex digits. This is the chip vendor OUI bits 3:18
> +		  BBBB - The value of the 16 bit Phy Identifier 2 register as
> +			 4 hex digits. This is the chip vendor OUI bits 19:24,
> +			 followed by 10 bits of a vendor specific ID.
> +- reg		: The ID number for the phy, usually a small integer

Please don't copy phy.txt. Just refer to it. Use text like:

The PHY device uses the binding described in
Documentation/devicetree/bindings/net/phy.txt

It may additionally have the following properties

> +Optional properties:
> +- vsc8531,edge-rate	: Edge rate sets the drive strength of the MAC
> +			  interface output signals.  Changing the drive
> +			  strength will affect the edge rate of the output
> +			  signal.

Are we specifying a rate or a strength? It is called edge-rate, so it
expect it to be a rate, mV/pS or something similar.

       Andrew
