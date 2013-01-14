From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware act_mirred
Date: Mon, 14 Jan 2013 15:10:03 -0500 (EST)
Message-ID: <20130114.151003.1602167424633098717.davem@davemloft.net>
References: <1358099194.8744.311.camel@edumazet-glaptop>
	<50F40489.70105@mojatatu.com>
	<20130114151539.GO5259@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757679Ab3ANUKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:10:06 -0500
In-Reply-To: <20130114151539.GO5259@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Mon, 14 Jan 2013 10:15:39 -0500

> Eric Dumazet pointed out that act_mirred needs to find the current net_ns,
> and struct net pointer is not provided in the call chain.  His original
> patch made use of current->nsproxy->net_ns to find the network namespace,
> but this fails to work correctly for userspace code that makes use of
> netlink sockets in different network namespaces.  Instead, pass the
> "struct net *" down along the call chain to where it is needed.
> 
> This version removes the ifb changes as Eric has submitted that patch 
> separately, but is otherwise identical to the previous version.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks.
