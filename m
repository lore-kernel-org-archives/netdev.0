From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Wed, 1 Feb 2017 12:02:09 -0600
Message-ID: <20170201180209.5l34ro335chhejhu@rob-hp-laptop>
References: <1485953626-25780-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1485953626-25780-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1485953626-25780-2-git-send-email-Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2017 at 06:23:46PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> 
> LED Mode:
> Microsemi PHY support 2 LEDs (LED[0] and LED[1]) to display different
> status information that can be selected by setting LED mode.
> 
> LED Mode parameter (vsc8531, led-0-mode) and (vsc8531, led-1-mode) get
> from Device Tree.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> ---
>  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 10 +++
>  drivers/net/phy/mscc.c                             | 85 +++++++++++++++++++++-
>  include/dt-bindings/net/mscc-phy-vsc8531.h         | 29 ++++++++
>  3 files changed, 123 insertions(+), 1 deletion(-)
>  create mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h
> 
> diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> index bdefefc6..bb7450c 100644
> --- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> +++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> @@ -27,6 +27,14 @@ Optional properties:
>  			  'vddmac'.
>  			  Default value is 0%.
>  			  Ref: Table:1 - Edge rate change (below).
> +- vsc8531,led-0-mode	: LED mode. Specify how the LED[0] should behave.

vsc8531 is not a vendor prefix. I see other properties did this, but 
please don't continue it.

> +			  Allowed values are define in
> +			  "include/dt-bindings/net/mscc-phy-vsc8531.h".
> +			  Default value is 1.
> +- vsc8531,led-1-mode	: LED mode. Specify how the LED[1] should behave.

Why not make this an array for LED0 and LED1?

> +			  Allowed values are define in
> +			  "include/dt-bindings/net/mscc-phy-vsc8531.h".
> +			  Default value is 2.
>  
>  Table: 1 - Edge rate change
>  ----------------------------------------------------------------|
> @@ -60,4 +68,6 @@ Example:
>                  compatible = "ethernet-phy-id0007.0570";
>                  vsc8531,vddmac		= <3300>;
>                  vsc8531,edge-slowdown	= <7>;
> +                vsc8531,led-0-mode	= <LINK_1000_ACTIVITY>;
> +                vsc8531,led-1-mode	= <LINK_100_ACTIVITY>;
>          };
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
