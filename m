From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4 0/4] net/macb: merge at91_ether driver into macb
 driver
Date: Sat, 07 Mar 2015 22:30:20 -0500 (EST)
Message-ID: <20150307.223020.1400708446360935463.davem@davemloft.net>
References: <1425709412-4935-1-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org,
	plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org, alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425709412-4935-1-git-send-email-boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Date: Sat,  7 Mar 2015 07:23:28 +0100

> The rm9200 boards use the dedicated at91_ether driver instead of the
> regular macb driver.
> 
> Both the macb and at91_ether drivers can be compiled as separated
> modules.
> Since the at91_ether driver uses code from the macb driver, at91_ether.ko
> depends on macb.ko.
> 
> However the macb.ko module always fails to load on rm9200 boards: the
> macb_probe() function expects a hclk clock which doesn't exist on rm9200.
> Then the at91_ether.ko can't be loaded in turn due to unresolved
> dependencies.
> 
> This series of patches fix this issue by merging at91_ether into macb.
> 
> Patch 1 is fixing a problem that might happen when enabling ARM
> multi-platform suppot.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
