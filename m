From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Tue, 07 Jun 2016 15:39:35 -0700 (PDT)
Message-ID: <20160607.153935.952593668152189228.davem@davemloft.net>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160604190301.GA8857@strlen.de>
	<1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, stasn77@gmail.com,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422669AbcFGWjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:39:36 -0400
In-Reply-To: <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Jun 2016 12:55:13 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> My prior attempt to fix the backlogs of parents failed.
> 
> If we return NET_XMIT_CN, our parents wont increase their backlog,
> so our qdisc_tree_reduce_backlog() should take this into account.
> 
> v2: Florian Westphal pointed out that we could drop the packet,
> so we need to save qdisc_pkt_len(skb) in a temp variable before
> calling fq_codel_drop()
> 
> Fixes: 9d18562a2278 ("fq_codel: add batch ability to fq_codel_drop()")
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> Reported-by: Stas Nichiporovich <stasn77@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
