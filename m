From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Zero flows on allocation.
Date: Sun, 20 Sep 2015 23:24:00 -0700 (PDT)
Message-ID: <20150920.232400.1768865193135146379.davem@davemloft.net>
References: <1442628374-57025-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755558AbbIUGYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 02:24:02 -0400
In-Reply-To: <1442628374-57025-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 18 Sep 2015 19:06:14 -0700

> @@ -80,7 +80,7 @@ struct sw_flow *ovs_flow_alloc(void)
>  	struct flow_stats *stats;
>  	int node;
>  
> -	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
> +	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL | __GFP_ZERO);
>  	if (!flow)

Like Eric, I prefer that you use kmem_cache_zalloc() to fix
this.

Thanks.
