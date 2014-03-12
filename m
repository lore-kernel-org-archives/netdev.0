From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] pkt_sched: allow scheduling points
Date: Tue, 11 Mar 2014 23:55:30 -0400 (EDT)
Message-ID: <20140311.235530.902777574751461523.davem@davemloft.net>
References: <1394496703-9278-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbaCLDzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 23:55:31 -0400
In-Reply-To: <1394496703-9278-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 10 Mar 2014 17:11:41 -0700

> We have seen delays of more than 50ms in class or qdisc dumps, in case
> device is under high TX stress, even with the prior 4KB per skb limit.
> 
> With the new 16KB limit, this could translate to 200ms delays.
> 
> Add cond_resched() to give a chance to higher prio tasks to get cpu.
> 
> But before doing so, we need to remove the rcu locking from tc_dump_qdisc()
> as David spotted.

Looks good, series applied, thanks Eric.
