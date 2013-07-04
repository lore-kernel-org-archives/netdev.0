From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipmr: change the prototype of
 ip_mr_forward().
Date: Thu, 04 Jul 2013 14:27:24 -0700 (PDT)
Message-ID: <20130704.142724.1657930430240129696.davem@davemloft.net>
References: <1372976155-2490-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756816Ab3GDV13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 17:27:29 -0400
In-Reply-To: <1372976155-2490-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Fri,  5 Jul 2013 01:15:55 +0300

> @@ -127,7 +127,7 @@ static struct kmem_cache *mrt_cachep __read_mostly;
>  static struct mr_table *ipmr_new_table(struct net *net, u32 id);
>  static void ipmr_free_table(struct mr_table *mrt);
>  
> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
>  			 struct sk_buff *skb, struct mfc_cache *cache,
>  			 int local);
>  static int ipmr_cache_report(struct mr_table *mrt,

When you change the column that the openning parenthesis of a function
declaration appears at, you must reindent all of the subsequent lines
of the declaration such that the first character lines up with the first
column after the openning parenthesis.

> @@ -1795,7 +1795,7 @@ static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
>  
>  /* "local" means that we should preserve one skb (for local delivery) */
>  
> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
>  			 struct sk_buff *skb, struct mfc_cache *cache,
>  			 int local)

Likewise.
