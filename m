From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] don't compare skb->network_header with
 skb->tail
Date: Sun, 10 Mar 2013 10:48:22 +0100
Message-ID: <1362908902.4051.31.camel@edumazet-glaptop>
References: <1362906925-45308-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, zhiguo.hong@emc.com
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:41263 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab3CJJs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 05:48:28 -0400
Received: by mail-ee0-f41.google.com with SMTP id c13so1762454eek.28
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 01:48:26 -0800 (PST)
In-Reply-To: <1362906925-45308-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-10 at 17:15 +0800, Hong Zhiguo wrote:
> in the case of NET_SKBUFF_DATA_USES_OFFSET(on 64-bit arch),
> skb->network_header is just offset over skb->head.
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 90cee5b..378e0b9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1705,7 +1705,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>  			skb_reset_mac_header(skb2);
>  
>  			if (skb_network_header(skb2) < skb2->data ||
> -			    skb2->network_header > skb2->tail) {
> +			    skb_network_header(skb2) > skb2->tail) {
>  				net_crit_ratelimited("protocol %04x is buggy, dev %s\n",
>  						     ntohs(skb2->protocol),
>  						     dev->name);

Sorry I dont understand this patch.

Could you elaborate ?
