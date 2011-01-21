From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Thu, 20 Jan 2011 23:31:44 -0800 (PST)
Message-ID: <20110120.233144.233395234.davem@davemloft.net>
References: <20110114095201.4fc58a45@nehalam>
	<1295028502.3937.116.camel@edumazet-laptop>
	<20110114110342.4d95ad5b@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	hadi@cyberus.ca, jarkao2@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38912
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753493Ab1AUHbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:31:10 -0500
In-Reply-To: <20110114110342.4d95ad5b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 14 Jan 2011 11:03:42 -0800

> From Eric Dumazet <eric.dumazet@gmail.com>
> 
> In commit 44b8288308ac9d (net_sched: pfifo_head_drop problem), we fixed
> a problem with pfifo_head drops that incorrectly decreased
> sch->bstats.bytes and sch->bstats.packets
> 
> Several qdiscs (CHOKe, SFQ, pfifo_head, ...) are able to drop a
> previously enqueued packet, and bstats cannot be changed, so
> bstats/rates are not accurate (over estimated)
> 
> This patch changes the qdisc_bstats updates to be done at dequeue() time
> instead of enqueue() time. bstats counters no longer account for dropped
> frames, and rates are more correct, since enqueue() bursts dont have
> effect on dequeue() rate.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6, thanks everyone.
