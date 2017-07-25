From: Sergey Matyukevich <sergey.matyukevich.os-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org>
Subject: Re: [PATCH] qtfnmac: Tidy up DMA mask setting
Date: Wed, 26 Jul 2017 01:00:52 +0300
Message-ID: <20170725220050.eksg3j53lemrhgdd@bars>
References: <2c3f47792b2e38d5584d641d98e82f8318fefc72.1500917445.git.robin.murphy@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: imitsyanko-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org, avinashp-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org,
        smatyukevich-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2c3f47792b2e38d5584d641d98e82f8318fefc72.1500917445.git.robin.murphy-5wv7dgnIgG8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> As the only caller of dma_supported() outside of DMA API internals, the
> qtfnmac driver stands out and invites scrutiny. Thankfully, it's not
> being used for evil, but it is entirely redundant, since it open-codes a
> check that the DMA mask setting functions are going to perform anyway.
> In fact, the whole qtnf_pcie_init_dma_mask() function is nothing more
> than a rather long-winded implementation of dma_set_mask_and_coherent(),
> so let's just use that directly.
> 
> Signed-off-by: Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>


Nice, thanks you !

Acked-by: Sergey Matyukevich <sergey.matyukevich.os-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org>
