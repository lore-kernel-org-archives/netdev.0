From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: qdisc dismantle fixes
Date: Mon, 30 Sep 2013 15:51:53 -0400 (EDT)
Message-ID: <20130930.155153.1283327919285197674.davem@davemloft.net>
References: <1380316801.30872.37.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352Ab3I3Tv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:51:57 -0400
In-Reply-To: <1380316801.30872.37.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Sep 2013 14:20:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> fq_reset() should drops all packets in queue, including
> throttled flows.
> 
> This patch moves code from fq_destroy() to fq_reset()
> to do the cleaning.
> 
> fq_change() must stop calling fq_dequeue() if all remaining
> packets are from throttled flows.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
