From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 02/10] net: Use SKB_WITH_OVERHEAD in build_skb
Date: Tue, 10 Apr 2012 16:58:36 +0200
Message-ID: <1334069916.5300.54.camel@edumazet-glaptop>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-2-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64685 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758990Ab2DJO6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 10:58:42 -0400
Received: by mail-bk0-f46.google.com with SMTP id ik5so4302194bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 07:58:41 -0700 (PDT)
In-Reply-To: <1334067984-7706-2-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 15:26 +0100, Ian Campbell wrote:
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> ---
>  net/core/skbuff.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 59a1ecb..d4e139e 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -264,7 +264,7 @@ struct sk_buff *build_skb(void *data)
>  	if (!skb)
>  		return NULL;
>  
> -	size = ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> +	size = SKB_WITH_OVERHEAD(ksize(data));
>  
>  	memset(skb, 0, offsetof(struct sk_buff, tail));
>  	skb->truesize = SKB_TRUESIZE(size);

Well, why not ;)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
