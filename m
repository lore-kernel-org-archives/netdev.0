From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 1/1] xen-netback: remove compilation warning
Date: Thu, 26 Feb 2015 10:13:44 +0000
Message-ID: <20150226101344.GB1824@zion.uk.xensource.com>
References: <1424939141-30730-1-git-send-email-marzo.pedro@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
To: pedro <marzo.pedro@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:4413 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbbBZKOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 05:14:36 -0500
Content-Disposition: inline
In-Reply-To: <1424939141-30730-1-git-send-email-marzo.pedro@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 09:25:41AM +0100, pedro wrote:
> From: pmarzo <marzo.pedro@gmail.com>
> 
> offset and size are of type uint16_t so the %lu gives a warning
> A %u specifier, the same used in size makes gcc happy
> Not sure if a %x would be more correct
> 
> Signed-off-by: Pedro Marzo Perez <marzo.pedro@gmail.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks

> ---
>  drivers/net/xen-netback/netback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index f7a31d2..3888a2b 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1248,7 +1248,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
>  		/* No crossing a page as the payload mustn't fragment. */
>  		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
>  			netdev_err(queue->vif->dev,
> -				   "txreq.offset: %x, size: %u, end: %lu\n",
> +				   "txreq.offset: %x, size: %u, end: %u\n",
>  				   txreq.offset, txreq.size,
>  				   (txreq.offset&~PAGE_MASK) + txreq.size);
>  			xenvif_fatal_tx_err(queue->vif);
> -- 
> 1.9.1
