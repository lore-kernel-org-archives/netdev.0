From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 2/2] xen-netback: Remove __GFP_COLD
Date: Wed, 29 Oct 2014 11:05:28 +0000
Message-ID: <20141029110528.GE23982@zion.uk.xensource.com>
References: <1414510171-12853-1-git-send-email-david.vrabel@citrix.com>
 <1414510171-12853-3-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Zoltan Kiss <zoltan.kiss@linaro.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:7110 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932259AbaJ2LFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2014 07:05:52 -0400
Content-Disposition: inline
In-Reply-To: <1414510171-12853-3-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 03:29:31PM +0000, David Vrabel wrote:
> From: Zoltan Kiss <zoltan.kiss@linaro.org>
> 
> This flag is unnecessary, it came from some old code.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Zoltan Kiss <zoltan.kiss@linaro.org>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 25f4c06..730252c 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1550,7 +1550,7 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
>  		unsigned int len;
>  
>  		BUG_ON(i >= MAX_SKB_FRAGS);
> -		page = alloc_page(GFP_ATOMIC|__GFP_COLD);
> +		page = alloc_page(GFP_ATOMIC);
>  		if (!page) {
>  			int j;
>  			skb->truesize += skb->data_len;
> -- 
> 1.7.10.4
