From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH] cxgb4: fix kfree(skb)
Date: Tue, 22 Jun 2010 00:09:31 -0700
Message-ID: <4C2061AB.3000400@chelsio.com>
References: <20100622070551.GA10062@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Denis Kirjanov <dkirjanov@hera.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11850 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab0FVHL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 03:11:59 -0400
In-Reply-To: <20100622070551.GA10062@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Kirjanov wrote:
> Use kfree_skb for skb pointers
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Yes, thank you.

Acked-by: Dimitris Michailidis <dm@chelsio.com>

> ---
> drivers/net/cxgb4/l2t.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/cxgb4/l2t.c b/drivers/net/cxgb4/l2t.c
> index 5b990d2..e8f0f55 100644
> --- a/drivers/net/cxgb4/l2t.c
> +++ b/drivers/net/cxgb4/l2t.c
> @@ -314,7 +314,7 @@ static void t4_l2e_free(struct l2t_entry *e)
>  			struct sk_buff *skb = e->arpq_head;
>  
>  			e->arpq_head = skb->next;
> -			kfree(skb);
> +			kfree_skb(skb);
>  		}
>  		e->arpq_tail = NULL;
>  	}

