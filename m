From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [6/8]
Date: Thu, 19 Jul 2007 07:15:24 -0700
Message-ID: <20070719141524.GE12892@xyzzy.farnsworth.org>
References: <469EEEC8.5040805@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:2323 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S938484AbXGSOP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 10:15:26 -0400
Content-Disposition: inline
In-Reply-To: <469EEEC8.5040805@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 04:55:36AM +0000, Steven J. Hill wrote:
> Fix the TX bytes statistics counter to, um, actually count.
> 
> Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
> ---

> --- linux-2.6.22.1/drivers/net/mv643xx_eth.c	2007-07-18 21:51:49.000000000 -0500
> +++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c	2007-07-18 21:44:07.000000000 -0500
> @@ -1506,7 +1511,7 @@
>  	spin_lock_irqsave(&mp->lock, flags);
>  
>  	eth_tx_submit_descs_for_skb(mp, skb);
> -	stats->tx_bytes = skb->len;
> +	stats->tx_bytes += skb->len;
>  	stats->tx_packets++;
>  	dev->trans_start = jiffies;
>  

Good fix, thanks.  Please resubmit per the guidelines in
Documentation/SubmittingPatches.

-Dale
