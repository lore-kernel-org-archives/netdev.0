From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix comment typo for __skb_alloc_pages()
Date: Fri, 30 Aug 2013 07:10:03 -0700
Message-ID: <1377871803.7360.0.camel@edumazet-glaptop>
References: <1377869297-19805-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:38455 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755723Ab3H3OKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 10:10:05 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so1893512pbc.40
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 07:10:04 -0700 (PDT)
In-Reply-To: <1377869297-19805-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-30 at 14:28 +0100, Florian Fainelli wrote:
> The name of the function in the comment is __skb_alloc_page() while we
> are actually commenting __skb_alloc_pages(). Fix this typo.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  include/linux/skbuff.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 5ac96f3..3a81e4b 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1906,7 +1906,7 @@ static inline struct sk_buff *netdev_alloc_skb_ip_align(struct net_device *dev,
>  }
>  
>  /*
> - *	__skb_alloc_page - allocate pages for ps-rx on a skb and preserve pfmemalloc data
> + *	__skb_alloc_pages - allocate pages for ps-rx on a skb and preserve pfmemalloc data
>   *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
>   *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
>   *	@order: size of the allocation

What about making this a real kerneldoc comment ?

/**

instead of

/*
