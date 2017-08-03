From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/5] net: stmmac: Add Adaptrum Anarion GMAC glue layer
Date: Thu, 3 Aug 2017 18:26:43 -0500
Message-ID: <20170803232643.oqvdgvp6xqwgk6mh@rob-hp-laptop>
References: <20170728220707.13960-1-alex.g@adaptrum.com>
 <20170728220707.13960-4-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexandru Gagniuc <alex.g-JVBBi1ABkv5Wk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170728220707.13960-4-alex.g-JVBBi1ABkv5Wk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 03:07:03PM -0700, Alexandru Gagniuc wrote:
> Before the GMAC on the Anarion chip can be used, the PHY interface
> selection must be configured with the DWMAC block in reset.
> 
> This layer covers a block containing only two registers. Although it
> is possible to model this as a reset controller and use the "resets"
> property of stmmac, it's much more intuitive to include this in the
> glue layer instead.
> 
> At this time only RGMII is supported, because it is the only mode
> which has been validated hardware-wise.
> 
> Signed-off-by: Alexandru Gagniuc <alex.g-JVBBi1ABkv5Wk0Htik3J/w@public.gmane.org>
> ---
>  .../devicetree/bindings/net/anarion-gmac.txt       |  25 ++++

The binding looks fine, but please split to separate patch.

>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |   9 ++
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>  .../net/ethernet/stmicro/stmmac/dwmac-anarion.c    | 151 +++++++++++++++++++++
>  4 files changed, 186 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/anarion-gmac.txt
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-anarion.c
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
