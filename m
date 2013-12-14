From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: set root qdisc before change() in
 attach_default_qdiscs()
Date: Sat, 14 Dec 2013 01:20:30 -0500 (EST)
Message-ID: <20131214.012030.1055733981305952689.davem@davemloft.net>
References: <1386891716.19078.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab3LNGUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 01:20:32 -0500
In-Reply-To: <1386891716.19078.119.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Dec 2013 15:41:56 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 95dc19299f74 ("pkt_sched: give visibility to mq slave
> qdiscs") we call disc_list_add() while the device qdisc might be
> the noop_qdisc one.
> 
> This shows up as duplicates in "tc qdisc show", as all inactive devices
> point to noop_qdisc.
> 
> Fix this by setting dev->qdisc to the new qdisc before calling
> ops->change() in attach_default_qdiscs()
> 
> Add a WARN_ON_ONCE() to catch any future similar problem.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
