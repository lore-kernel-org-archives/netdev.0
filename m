From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] cpsw: Add support to read cpu MAC address
Date: Mon, 14 Jan 2013 20:26:51 +0000
Message-ID: <20130114202651.5360F3E249D@localhost>
References: <1357917302-32550-1-git-send-email-michal.bachraty@streamunlimited.com>
Cc: devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org,
	Michal Bachraty <michal.bachraty@streamunlimited.com>
To: Michal Bachraty <michal.bachraty@streamunlimited.com>,
	rob.herring@calxeda.com, rob@landley.net, linux@arm.linux.org.uk
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1357917302-32550-1-git-send-email-michal.bachraty@streamunlimited.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Jan 2013 16:15:02 +0100, Michal Bachraty <michal.bachraty@streamunlimited.com> wrote:
> Signed-off-by: Michal Bachraty <michal.bachraty@streamunlimited.com>
> ---
>  Documentation/devicetree/bindings/net/cpsw.txt |   10 +-
>  arch/arm/boot/dts/am33xx.dtsi                  |    5 +-
>  drivers/net/ethernet/ti/cpsw.c                 |  121 +++++++++++++++++++++---
>  include/linux/platform_data/cpsw.h             |    8 ++
>  4 files changed, 128 insertions(+), 16 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
> index dcaabe9..432122c 100644
> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
> @@ -4,7 +4,7 @@ TI SoC Ethernet Switch Controller Device Tree Bindings
>  Required properties:
>  - compatible		: Should be "ti,cpsw"
>  - reg			: physical base address and size of the cpsw
> -			  registers map
> +			  registers map and mac-address cpu config registers
>  - interrupts		: property with a value describing the interrupt
>  			  number
>  - interrupt-parent	: The parent interrupt controller
> @@ -25,17 +25,23 @@ Required properties:
>  - slave_reg_ofs		: Specifies slave register offset
>  - sliver_reg_ofs	: Specifies slave sliver register offset
>  - phy_id		: Specifies slave phy id
> -- mac-address		: Specifies slave MAC address
>  
>  Optional properties:
>  - ti,hwmods		: Must be "cpgmac0"
>  - no_bd_ram		: Must be 0 or 1
> +- mac-address-source 	: Specifies source of MAC address ("user-defined-mac",
> +			  "cpu-id0-mac", "cpu-id01-mac", "random-mac"). If not
> +			  specified, "cpu-id0-mac" is selected

Drop the '-mac' suffix on the values. The property is already named
"mac-address-source", so I think it is already unambiguious from the
context.  :-)

Otherwise the patch looks good to me, but I haven't gone over the code
in fine detail.

Acked-by: Grant Likely <grant.likely@secretlab.ca>

