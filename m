From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net_sched: bulk dequeue and deferred drops
Date: Sat, 25 Jun 2016 12:20:20 -0400 (EDT)
Message-ID: <20160625.122020.739429682078560293.davem@davemloft.net>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	brouer@redhat.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbcFYQUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:20:24 -0400
In-Reply-To: <1466576212-15012-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 21 Jun 2016 23:16:48 -0700

> First patch adds an additional parameter to ->enqueue() qdisc method
> so that drops can be done outside of critical section
> (after locks are released).
> 
> Then fq_codel can have a small optimization to reduce number of cache
> lines misses during a drop event
> (possibly accumulating hundreds of packets to be freed).
> 
> A small htb change exports the backlog in class dumps.
> 
> Final patch adds bulk dequeue to qdiscs that were lacking this feature.
> 
> This series brings a nice qdisc performance increase (more than 80 %
> in some cases).

Series applied, thanks Eric.
