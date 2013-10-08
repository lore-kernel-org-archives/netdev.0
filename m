From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: increment drop counters in
 qdisc_tree_decrease_qlen()
Date: Tue, 08 Oct 2013 16:51:24 -0400 (EDT)
Message-ID: <20131008.165124.1061477322585989569.davem@davemloft.net>
References: <1381159952.12191.14.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756606Ab3JHUv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:51:28 -0400
In-Reply-To: <1381159952.12191.14.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Oct 2013 08:32:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> qdisc_tree_decrease_qlen() is called when some packets are dropped
> on a qdisc, and we want to notify parents of qlen changes.
> 
> We also can increment parents qdisc qstats drop counters.
> 
> This permits more accurate drop counters up to root qdisc.
> 
> For example a graft operation typically resets a qdisc 
> (drops all packets) and call qdisc_tree_decrease_qlen()
> 
> Note that callers are responsible for their drop counters.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
