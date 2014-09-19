From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] net: sched: cls_u32: rcu can not be last
 node
Date: Fri, 19 Sep 2014 17:06:18 -0400 (EDT)
Message-ID: <20140919.170618.667860827121228844.davem@davemloft.net>
References: <20140917181144.9571.68528.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757831AbaISVGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:06:22 -0400
In-Reply-To: <20140917181144.9571.68528.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 17 Sep 2014 11:11:46 -0700

> tc_u32_sel 'sel' in tc_u_knode expects to be the last element in the
> structure and pads the structure with tc_u32_key fields for each key.
> 
>  kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL)
> 
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks John.
