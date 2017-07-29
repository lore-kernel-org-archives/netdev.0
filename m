From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3/5] net: stmmac: Add Adaptrum Anarion GMAC glue layer
Date: Fri, 28 Jul 2017 19:01:55 -0700 (PDT)
Message-ID: <20170728.190155.457209566729295513.davem@davemloft.net>
References: <20170728220707.13960-1-alex.g@adaptrum.com>
        <20170728220707.13960-4-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alex.g-JVBBi1ABkv5Wk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170728220707.13960-4-alex.g-JVBBi1ABkv5Wk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexandru Gagniuc <alex.g-JVBBi1ABkv5Wk0Htik3J/w@public.gmane.org>
Date: Fri, 28 Jul 2017 15:07:03 -0700

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

I don't see how this fits into any patch series at all.  If this is
part of a series you posted elsewhere, you should keep netdev@ on
all such postings so people there can review the change in-context.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
