From: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Subject: Re: [PATCH] dt-binding: net/phy: fix interrupts description
Date: Mon, 28 Aug 2017 13:20:39 +0300
Message-ID: <20170828102039.wdylojqcrn2avv2f@tarshish>
References: <b3756346473feadfeba70ecb71960cad48e66621.1503468660.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <b3756346473feadfeba70ecb71960cad48e66621.1503468660.git.baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Wed, Aug 23, 2017 at 09:11:00AM +0300, Baruch Siach wrote:
> Commit b053dc5a722ea (powerpc: Refactor device tree binding) split the
> Ethernet PHY binding documentation out of the big booting-without-of.txt
> file, leaving a dangling reference to "section 2" in the 'interrupts'
> property description. Drop that reference, and make the description look
> more like the rest.
> 
> While at it, make the example interrupt-parent phandle look more like a
> real world phandle, and use an IRQ_TYPE_ macro for the 'interrupts'
> type.

This patch is now marked 'Not Applicable' in the netdev patchwork. Why is 
that? Should it go through some other tree?

baruch

> Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/phy.txt | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
> index b55857696fc3..86ba72af6163 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -2,11 +2,7 @@ PHY nodes
>  
>  Required properties:
>  
> - - interrupts : <a b> where a is the interrupt number and b is a
> -   field that represents an encoding of the sense and level
> -   information for the interrupt.  This should be encoded based on
> -   the information in section 2) depending on the type of interrupt
> -   controller you have.
> + - interrupts : interrupt specifier for the sole interrupt.
>   - interrupt-parent : the phandle for the interrupt controller that
>     services interrupts for this device.
>   - reg : The ID number for the phy, usually a small integer
> @@ -56,7 +52,7 @@ Example:
>  
>  ethernet-phy@0 {
>  	compatible = "ethernet-phy-id0141.0e90", "ethernet-phy-ieee802.3-c22";
> -	interrupt-parent = <40000>;
> -	interrupts = <35 1>;
> +	interrupt-parent = <&PIC>;
> +	interrupts = <35 IRQ_TYPE_EDGE_RISING>;
>  	reg = <0>;
>  };

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org - tel: +972.52.368.4656, http://www.tkos.co.il -
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
