From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 3/4] net: sched: restrict use of qstats qlen
Date: Tue, 30 Sep 2014 01:03:06 -0400 (EDT)
Message-ID: <20140930.010306.274182520689361087.davem@davemloft.net>
References: <20140928185255.1976.56179.stgit@nitbit.x32>
	<20140928185356.1976.19980.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbaI3FDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 01:03:07 -0400
In-Reply-To: <20140928185356.1976.19980.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 28 Sep 2014 11:53:57 -0700

> This removes the use of qstats->qlen variable from the classifiers
> and makes it an explicit argument to gnet_stats_copy_queue().
> 
> The qlen represents the qdisc queue length and is packed into
> the qstats at the last moment before passnig to user space. By
> handling it explicitely we avoid, in the percpu stats case, having
> to figure out which per_cpu variable to put it in.
> 
> It would probably be best to remove it from qstats completely
> but qstats is a user space ABI and can't be broken. A future
> patch could make an internal only qstats structure that would
> avoid having to allocate an additional u32 variable on the
> Qdisc struct. This would make the qstats struct 128bits instead
> of 128+32.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
