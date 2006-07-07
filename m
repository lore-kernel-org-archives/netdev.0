From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Fri, 7 Jul 2006 15:52:55 -0700
Message-ID: <20060707155255.10f2e10f@dxpl.pdx.osdl.net>
References: <20060707090956.GA2543@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40105 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751018AbWGGWxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 18:53:01 -0400
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20060707090956.GA2543@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 7 Jul 2006 11:09:57 +0200
Christoph Hellwig <hch@lst.de> wrote:

> dev_alloc_skb is designated for RX descriptors, not TX.  (Some drivers
> use it for the latter anyway, but that's a different story)
> 
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Index: linux-2.6/include/linux/skbuff.h
> ===================================================================
> --- linux-2.6.orig/include/linux/skbuff.h	2006-07-07 11:05:30.000000000 +0200
> +++ linux-2.6/include/linux/skbuff.h	2006-07-07 11:06:31.000000000 +0200
> @@ -1067,7 +1067,7 @@
>  }
>  
>  /**
> - *	__dev_alloc_skb - allocate an skbuff for sending
> + *	__dev_alloc_skb - allocate an skbuff for receiving
>   *	@length: length to allocate
>   *	@gfp_mask: get_free_pages mask, passed to alloc_skb
>   *
> @@ -1088,7 +1088,7 @@
>  }
>  
>  /**
> - *	dev_alloc_skb - allocate an skbuff for sending
> + *	dev_alloc_skb - allocate an skbuff for receiving
>   *	@length: length to allocate
>   *
>   *	Allocate a new &sk_buff and assign it a usage count of one. The
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

What is the point of dev_alloc_skb anyway? all it does is add header space.

-- 
Stephen Hemminger <shemminger@osdl.org>
Quis custodiet ipsos custodes?
