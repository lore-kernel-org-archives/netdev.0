From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Wed, 15 Feb 2017 10:45:40 -0600
Message-ID: <20170215164540.eok7bnudfffzoyi4@rob-hp-laptop>
References: <1486474826-29426-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1486474826-29426-1-git-send-email-Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2017 at 07:10:26PM +0530, Raju Lakkaraju wrote:
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
> Change set:
> v0:
> - Initial version of LED driver for Microsemi PHYs.
> v1:
> - Update all review comments given by Andrew.
> - Add new header file "mscc-phy-vsc8531.h" to define DT macros.
> - Add error/range check for DT LED mode input
> v2:
> - Fixed x86_64 build error.
> v3:
> - Update all review comments.
> - Fix the error check condition.
> 
>  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 10 +++
>  drivers/net/phy/mscc.c                             | 85 +++++++++++++++++++++-
>  include/dt-bindings/net/mscc-phy-vsc8531.h         | 29 ++++++++
>  3 files changed, 123 insertions(+), 1 deletion(-)
>  create mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h
> 
> diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> index bdefefc6..0eedabe 100644
> --- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> +++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> @@ -27,6 +27,14 @@ Optional properties:
>  			  'vddmac'.
>  			  Default value is 0%.
>  			  Ref: Table:1 - Edge rate change (below).
> +- vsc8531,led-0-mode	: LED mode. Specify how the LED[0] should behave.
> +			  Allowed values are define in
> +			  "include/dt-bindings/net/mscc-phy-vsc8531.h".
> +			  Default value is VSC8531_LINK_1000_ACTIVITY (1).
> +- vsc8531,led-1-mode	: LED mode. Specify how the LED[1] should behave.

You failed to address my comment on v2. vsc8531 is not a vendor prefix. 
Please fix in a new patch since David already applied it.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
