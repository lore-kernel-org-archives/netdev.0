From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 1/4] net: sched: make bstats per cpu and
 estimator RCU safe
Date: Tue, 30 Sep 2014 01:02:52 -0400 (EDT)
Message-ID: <20140930.010252.1632977911084328063.davem@davemloft.net>
References: <20140928185255.1976.56179.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbaI3FCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 01:02:54 -0400
In-Reply-To: <20140928185255.1976.56179.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 28 Sep 2014 11:52:56 -0700

> From: John Fastabend <john.fastabend@gmail.com>
> 
> In order to run qdisc's without locking statistics and estimators
> need to be handled correctly.
> 
> To resolve bstats make the statistics per cpu. And because this is
> only needed for qdiscs that are running without locks which is not
> the case for most qdiscs in the near future only create percpu
> stats when qdiscs set the TCQ_F_CPUSTATS flag.
> 
> Next because estimators use the bstats to calculate packets per
> second and bytes per second the estimator code paths are updated
> to use the per cpu statistics.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
