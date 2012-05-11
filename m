From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: update bstats in dequeue()
Date: Thu, 10 May 2012 23:36:04 -0400 (EDT)
Message-ID: <20120510.233604.758236662455118985.davem@davemloft.net>
References: <1336664194.31653.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932919Ab2EKDgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:36:07 -0400
In-Reply-To: <1336664194.31653.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 May 2012 17:36:34 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Class bytes/packets stats can be misleading because they are updated in
> enqueue() while packet might be dropped later.
> 
> We already fixed all qdiscs but sch_atm.
> 
> This patch makes the final cleanup.
> 
> class rate estimators can now match qdisc ones.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
