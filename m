From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: more robust memory
 allocation
Date: Tue, 17 Dec 2013 15:25:51 -0500 (EST)
Message-ID: <20131217.152551.2027690479525731520.davem@davemloft.net>
References: <1386894912.19078.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387142125.19078.219.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab3LQUZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:25:53 -0500
In-Reply-To: <1387142125.19078.219.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 Dec 2013 13:15:25 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch brings NUMA support and automatic fallback to vmalloc()
> in case kmalloc() failed to allocate FQ hash table.
> 
> NUMA support depends on XPS being setup for the device before
> qdisc allocation. After a XPS change, it might be worth creating
> qdisc hierarchy again.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
