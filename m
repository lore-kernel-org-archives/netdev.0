From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: suspicious RCU usage in qdisc_watchdog
Date: Sat, 04 Oct 2014 20:46:15 -0400 (EDT)
Message-ID: <20141004.204615.153993151788265529.davem@davemloft.net>
References: <20141003054306.20821.48420.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaJEAqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:46:16 -0400
In-Reply-To: <20141003054306.20821.48420.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Thu, 02 Oct 2014 22:43:09 -0700

> Suspicious RCU usage in qdisc_watchdog call needs to be done inside
> rcu_read_lock/rcu_read_unlock. And then Qdisc destroy operations
> need to ensure timer is cancelled before removing qdisc structure.
 ...
> Fixes: b26b0d1e8b1 ("net: qdisc: use rcu prefix and silence sparse warnings")
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thank you.
