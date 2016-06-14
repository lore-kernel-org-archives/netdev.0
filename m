From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: fix pfifo_head_drop behavior vs backlog
Date: Tue, 14 Jun 2016 17:19:34 -0400 (EDT)
Message-ID: <20160614.171934.446947069434231926.davem@davemloft.net>
References: <1465786885.7945.140.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932452AbcFNVTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:19:38 -0400
In-Reply-To: <1465786885.7945.140.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 12 Jun 2016 20:01:25 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When the qdisc is full, we drop a packet at the head of the queue,
> queue the current skb and return NET_XMIT_CN
> 
> Now we track backlog on upper qdiscs, we need to call
> qdisc_tree_reduce_backlog(), even if the qlen did not change.
> 
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
