From: Djalal Harouni <tixxdz-Umm1ozX2/EEdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] drivers/iwlwifi: use dma_zalloc_coherent() for DMA
 allocation
Date: Wed, 21 Dec 2011 20:48:52 +0100
Message-ID: <20111221194852.GA19795@dztty>
References: <20111221002147.GA4996@dztty>
 <1324486330.13074.322.camel@wwguy-huron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1324486330.13074.322.camel@wwguy-huron>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2011 at 08:52:10AM -0800, Guy, Wey-Yi wrote:
> Hi Djalal,
> 
> 
> On Tue, 2011-12-20 at 16:21 -0800, Djalal Harouni wrote:
> > Replace dma_alloc_coherent()+memset() with the new dma_zalloc_coherent()
> > 
> > Signed-off-by: Djalal Harouni <tixxdz-Umm1ozX2/EEdnm+yROfE0A@public.gmane.org>
> > ---
> 
> iwl-trans-pcie.c is one of the source files in iwlwifi driver hold
> dual-license (GPL + BSD), are you ok to release your code for the BSD
> license and relinquish the copyright?
Yes, It's ok.

> btw, we are in the process of rewrite and re-architect major portion of
> iwlwifi driver, and we also plan to make most of the code dual-license
> (GPL + BSD).
>
> Thanks you in advance
> 
> Wey
Thanks Wey.

-- 
tixxdz
http://opendz.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
