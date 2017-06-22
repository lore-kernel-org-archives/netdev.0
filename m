From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH] dt-bindings: gpmc: Correct location of generic gpmc
 binding
Date: Thu, 22 Jun 2017 21:14:52 +0200
Message-ID: <20170622211452.50617c4e@bbrezillon>
References: <1498047294-31075-1-git-send-email-trini@konsulko.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mtd@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Mark Rutland <mark.rutland@arm.com>,
        Richard Weinberger <richard@nod.at>,
        Marek Vasut <marek.vasut@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>,
        Brian Norris <computersforpeace@gmail.com>,
        David Woodhouse <dwmw2@infradead.org>
To: Tom Rini <trini@konsulko.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:50261 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752392AbdFVTO7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 15:14:59 -0400
In-Reply-To: <1498047294-31075-1-git-send-email-trini@konsulko.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jun 2017 08:14:54 -0400
Tom Rini <trini@konsulko.com> wrote:

> The binding bus/ti-gpmc.txt has been moved to
> memory-controllers/omap-gpmc.txt.  Update all references to this in
> order to make reading and understanding a given binding easier.
> 
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: Brian Norris <computersforpeace@gmail.com>
> Cc:Boris Brezillon <boris.brezillon@free-electrons.com>
> Cc: Marek Vasut <marek.vasut@gmail.com>
> Cc: Richard Weinberger <richard@nod.at>
> Cc: Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>
> Cc: Rob Herring <robh+dt@kernel.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Signed-off-by: Tom Rini <trini@konsulko.com>

Applied.

Thanks,

Boris

> ---
>  Documentation/devicetree/bindings/mtd/gpmc-nand.txt    | 2 +-
>  Documentation/devicetree/bindings/mtd/gpmc-nor.txt     | 4 ++--
>  Documentation/devicetree/bindings/mtd/gpmc-onenand.txt | 2 +-
>  Documentation/devicetree/bindings/net/gpmc-eth.txt     | 4 ++--
>  4 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/mtd/gpmc-nand.txt b/Documentation/devicetree/bindings/mtd/gpmc-nand.txt
> index 174f68c26c1b..dd559045593d 100644
> --- a/Documentation/devicetree/bindings/mtd/gpmc-nand.txt
> +++ b/Documentation/devicetree/bindings/mtd/gpmc-nand.txt
> @@ -5,7 +5,7 @@ the GPMC controller with a name of "nand".
>  
>  All timing relevant properties as well as generic gpmc child properties are
>  explained in a separate documents - please refer to
> -Documentation/devicetree/bindings/bus/ti-gpmc.txt
> +Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
>  
>  For NAND specific properties such as ECC modes or bus width, please refer to
>  Documentation/devicetree/bindings/mtd/nand.txt
> diff --git a/Documentation/devicetree/bindings/mtd/gpmc-nor.txt b/Documentation/devicetree/bindings/mtd/gpmc-nor.txt
> index 4828c17bb784..131d3a74d0bd 100644
> --- a/Documentation/devicetree/bindings/mtd/gpmc-nor.txt
> +++ b/Documentation/devicetree/bindings/mtd/gpmc-nor.txt
> @@ -5,7 +5,7 @@ child nodes of the GPMC controller with a name of "nor".
>  
>  All timing relevant properties as well as generic GPMC child properties are
>  explained in a separate documents. Please refer to
> -Documentation/devicetree/bindings/bus/ti-gpmc.txt
> +Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
>  
>  Required properties:
>  - bank-width: 		Width of NOR flash in bytes. GPMC supports 8-bit and
> @@ -28,7 +28,7 @@ Required properties:
>  
>  Optional properties:
>  - gpmc,XXX		Additional GPMC timings and settings parameters. See
> -			Documentation/devicetree/bindings/bus/ti-gpmc.txt
> +			Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
>  
>  Optional properties for partition table parsing:
>  - #address-cells: should be set to 1
> diff --git a/Documentation/devicetree/bindings/mtd/gpmc-onenand.txt b/Documentation/devicetree/bindings/mtd/gpmc-onenand.txt
> index 5d8fa527c496..b6e8bfd024f4 100644
> --- a/Documentation/devicetree/bindings/mtd/gpmc-onenand.txt
> +++ b/Documentation/devicetree/bindings/mtd/gpmc-onenand.txt
> @@ -5,7 +5,7 @@ the GPMC controller with a name of "onenand".
>  
>  All timing relevant properties as well as generic gpmc child properties are
>  explained in a separate documents - please refer to
> -Documentation/devicetree/bindings/bus/ti-gpmc.txt
> +Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
>  
>  Required properties:
>  
> diff --git a/Documentation/devicetree/bindings/net/gpmc-eth.txt b/Documentation/devicetree/bindings/net/gpmc-eth.txt
> index ace4a64b3695..f7da3d73ca1b 100644
> --- a/Documentation/devicetree/bindings/net/gpmc-eth.txt
> +++ b/Documentation/devicetree/bindings/net/gpmc-eth.txt
> @@ -9,7 +9,7 @@ the GPMC controller with an "ethernet" name.
>  
>  All timing relevant properties as well as generic GPMC child properties are
>  explained in a separate documents. Please refer to
> -Documentation/devicetree/bindings/bus/ti-gpmc.txt
> +Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
>  
>  For the properties relevant to the ethernet controller connected to the GPMC
>  refer to the binding documentation of the device. For example, the documentation
> @@ -43,7 +43,7 @@ Required properties:
>  
>  Optional properties:
>  - gpmc,XXX		Additional GPMC timings and settings parameters. See
> -			Documentation/devicetree/bindings/bus/ti-gpmc.txt
> +			Documentation/devicetree/bindings/memory-controllers/omap-gpmc.txt
>  
>  Example:
>  
