From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: remove duplicated function definition
Date: Sun, 5 Jul 2015 20:48:22 +0100
Message-ID: <20150705194822.GA22267@zion.uk.xensource.com>
References: <1435951980-16265-1-git-send-email-liang.z.li@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: Liang Li <liang.z.li@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20860 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752609AbbGETs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2015 15:48:26 -0400
Content-Disposition: inline
In-Reply-To: <1435951980-16265-1-git-send-email-liang.z.li@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 04, 2015 at 03:33:00AM +0800, Liang Li wrote:
> There are two duplicated xenvif_zerocopy_callback() definitions.
> Remove one of them.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Please fix the time of your computer and resend.

Wei.

> ---
>  drivers/net/xen-netback/common.h | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 8a495b3..c6cb85a 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -325,9 +325,6 @@ static inline pending_ring_idx_t nr_pending_reqs(struct xenvif_queue *queue)
>  		queue->pending_prod + queue->pending_cons;
>  }
>  
> -/* Callback from stack when TX packet can be released */
> -void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success);
> -
>  irqreturn_t xenvif_interrupt(int irq, void *dev_id);
>  
>  extern bool separate_tx_rx_irq;
> -- 
> 1.9.1
