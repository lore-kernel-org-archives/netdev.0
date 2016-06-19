From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 12/15] net: davinci_mdio: document missed
 "ti,am4372-mdio" compat string
Date: Sun, 19 Jun 2016 09:35:43 -0500
Message-ID: <20160619143543.GA14844@rob-hp-laptop>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
 <20160615115603.4897-13-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	devicetree@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34996 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbcFSOft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 10:35:49 -0400
Content-Disposition: inline
In-Reply-To: <20160615115603.4897-13-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 02:56:00PM +0300, Grygorii Strashko wrote:
> Document missed "ti,am4372-mdio" compat string used for TI am437x SoC
> (am4372.dtsi).
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  Documentation/devicetree/bindings/net/davinci-mdio.txt | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/davinci-mdio.txt b/Documentation/devicetree/bindings/net/davinci-mdio.txt
> index 0369e25..f2bba50 100644
> --- a/Documentation/devicetree/bindings/net/davinci-mdio.txt
> +++ b/Documentation/devicetree/bindings/net/davinci-mdio.txt
> @@ -2,7 +2,8 @@ TI SoC Davinci/Keystone2 MDIO Controller Device Tree Bindings
>  ---------------------------------------------------
>  
>  Required properties:
> -- compatible		: Should be "ti,davinci_mdio" or "ti,keystone_mdio"
> +- compatible		: Should be "ti,davinci_mdio", "ti,keystone_mdio",
> +			  "ti,am4372-mdio"

This is still an OR relationship?

It's preferred to list one per line.

>  - reg			: physical base address and size of the davinci mdio
>  			  registers map
>  - bus_freq		: Mdio Bus frequency
> -- 
> 2.8.4
> 
