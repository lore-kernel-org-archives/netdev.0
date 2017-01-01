From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: stmmac: remove unused duplicate property
 snps,axi_all
Date: Sun, 01 Jan 2017 11:55:46 -0500 (EST)
Message-ID: <20170101.115546.156775699826522389.davem@davemloft.net>
References: <1483102609-21926-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, niklass-VrBV9hrLPhE@public.gmane.org, eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org,
        gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: niklas.cassel-VrBV9hrLPhE@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483102609-21926-1-git-send-email-niklass-VrBV9hrLPhE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
Date: Fri, 30 Dec 2016 13:56:46 +0100

> From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
> 
> For core revision 3.x Address-Aligned Beats is available in two registers.
> The DT property snps,aal was created for AAL in the DMA bus register,
> which is a read/write bit.
> The DT property snps,axi_all was created for AXI_AAL in the AXI bus mode
> register, which is a read only bit that reflects the value of AAL in the
> DMA bus register.
> 
> Since the value of snps,axi_all is never used in the driver,
> and since the property was created for a bit that is read only,
> it should be safe to remove the property.
> 
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
> Signed-off-by: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>

Applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
