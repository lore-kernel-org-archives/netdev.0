From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/6] dt-bindings: mdio-mux: Add documentation for mdio
 mux for NSP SoC
Date: Wed, 9 Nov 2016 15:34:25 +0100
Message-ID: <20161109143425.GE15386@lunn.ch>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
 <1478683994-12008-2-git-send-email-yendapally.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Kishon Vijay Abraham I <kishon@ti.com>,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60492 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753016AbcKIOek (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 09:34:40 -0500
Content-Disposition: inline
In-Reply-To: <1478683994-12008-2-git-send-email-yendapally.reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2016 at 04:33:09AM -0500, Yendapally Reddy Dhananjaya Reddy wrote:
> Add documentation for mdio mux available in Broadcom NSP SoC
> 
> Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
> ---
>  .../devicetree/bindings/net/brcm,mdio-mux-nsp.txt  | 57 ++++++++++++++++++++++
>  1 file changed, 57 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt b/Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt
> new file mode 100644
> index 0000000..b749a2b
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt
> @@ -0,0 +1,57 @@
> +Properties for an MDIO bus multiplexer available in Broadcom NSP SoC.
> +
> +This MDIO bus multiplexer defines buses that could access the internal
> +phys as well as external to SoCs. When child bus is selected, one needs

Hi Yendapally

Since we are in the networking subsystem, when we see phy, we think
Ethernet PHY. But broadcom mdio mux is generic and can have any sort
of PHY or device connected to it. To avoid confusion and
missunderstanding, please could you try to prefix each 'PHY' in the
with an indication of what type it is, 'Ethernet PHY', 'USB phy',
'SERDES PHY', or 'generic PHY/mdio device'.

And i mean this in general, not just this patch.

Thanks
	Andrew
