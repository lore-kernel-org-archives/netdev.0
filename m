From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 4/4] net: macb: Add hardware PTP support
Date: Sun, 4 Jun 2017 22:55:16 +0200
Message-ID: <20170604205516.GA7848@localhost.localdomain>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
 <1496413690-22826-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, andrei.pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org
To: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1496413690-22826-1-git-send-email-rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2017 at 03:28:10PM +0100, Rafal Ozieblo wrote:

> +int gem_get_hwtst(struct net_device *dev, struct ifreq *rq)
> +{
> +	struct macb *bp = netdev_priv(dev);
> +	struct hwtstamp_config *tstamp_config = &bp->tstamp_config;
> +
> +	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) == 0)
> +		return -EFAULT;

Segmentation fault?  Really?

...

> +int gem_set_hwtst(struct net_device *dev, struct ifreq *ifr, int cmd)
> +{
> +	struct macb *bp = netdev_priv(dev);
> +	struct hwtstamp_config *tstamp_config = &bp->tstamp_config;
> +	enum macb_bd_control tx_bd_control = TSTAMP_DISABLED;
> +	enum macb_bd_control rx_bd_control = TSTAMP_DISABLED;
> +	u32 regval;
> +
> +	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) == 0)
> +		return -EFAULT;

here again

Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
