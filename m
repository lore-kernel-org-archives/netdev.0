From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RESEND PATCH 1/3] bindings: net: stmmac: correct note about
 TSO
Date: Thu, 08 Dec 2016 11:35:48 -0500 (EST)
Message-ID: <20161208.113548.1569060543054922468.davem@davemloft.net>
References: <1481114469-4788-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org,
        eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org, niklass-VrBV9hrLPhE@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: niklas.cassel-VrBV9hrLPhE@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481114469-4788-1-git-send-email-niklass-VrBV9hrLPhE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
Date: Wed, 7 Dec 2016 13:41:06 +0100

> From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
> 
> snps,tso was previously placed under AXI BUS Mode parameters,
> suggesting that the property should be in the stmmac-axi-config node.
> 
> TSO (TCP Segmentation Offloading) has nothing to do with AXI BUS Mode
> parameters, and the parser actually expects it to be in the root node,
> not in the stmmac-axi-config.
> 
> Also added a note about snps,tso only being available on GMAC4 and newer.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
> Acked-by: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
> Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
