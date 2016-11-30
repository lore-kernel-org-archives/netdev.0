From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/4] bindings: net: stmmac: correct note about TSO
Date: Wed, 30 Nov 2016 14:41:07 -0600
Message-ID: <20161130204107.5w636jlptwrovntd@rob-hp-laptop>
References: <1479911066-19752-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>,
        Niklas Cassel <niklass-VrBV9hrLPhE@public.gmane.org>,
        Eric Engestrom <eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1479911066-19752-1-git-send-email-niklass-VrBV9hrLPhE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2016 at 03:24:25PM +0100, Niklas Cassel wrote:
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
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
