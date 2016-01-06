From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key
Date: Wed, 06 Jan 2016 01:18:35 -0500 (EST)
Message-ID: <20160106.011835.39198953316515142.davem@davemloft.net>
References: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wen.gang.wang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbcAFGSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 01:18:40 -0500
In-Reply-To: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wengang Wang <wen.gang.wang@oracle.com>
Date: Wed,  6 Jan 2016 13:49:28 +0800

> @@ -523,11 +523,20 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
>  			       const struct sock *sk)
>  {
>  	const struct iphdr *iph = ip_hdr(skb);
> -	int oif = skb->dev->ifindex;
> +	int oif;
> +	struct net_device *master = NULL;
> +
>  	u8 tos = RT_TOS(iph->tos);
>  	u8 prot = iph->protocol;
>  	u32 mark = skb->mark;
>  

Please fix the stlye of these variable declarations:

1) Order them from longest line to shortest line, also known
   as "reverse christmas tree" layout.

2) Do not add an empty line in the middle of these variable
   declarations.

Thanks.
