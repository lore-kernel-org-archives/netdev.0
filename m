From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: htb: do not acquire qdisc lock in
 dump operations
Date: Thu, 06 Mar 2014 17:26:10 -0500 (EST)
Message-ID: <20140306.172610.1610849095441712557.davem@davemloft.net>
References: <1394043274.27473.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbaCFW0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:26:12 -0500
In-Reply-To: <1394043274.27473.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Mar 2014 10:14:34 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> htb_dump() and htb_dump_class() do not strictly need to acquire
> qdisc lock to fetch qdisc and/or class parameters.
> 
> We hold RTNL and no changes can occur.
> 
> This reduces by 50% qdisc lock pressure while doing tc qdisc|class dump
> operations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Yep, this looks like a valid locking removal.

Applied, thanks!
