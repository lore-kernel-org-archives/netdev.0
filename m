From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: use __skb_queue_head_init() where
 applicable
Date: Fri, 19 Sep 2014 16:32:30 -0400 (EDT)
Message-ID: <20140919.163230.1207368398144682713.davem@davemloft.net>
References: <1410966305.7106.238.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757540AbaISUcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:32:32 -0400
In-Reply-To: <1410966305.7106.238.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Sep 2014 08:05:05 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> pfifo_fast and htb use skb lists, without needing their spinlocks.
> (They instead use the standard qdisc lock)
> 
> We can use __skb_queue_head_init() instead of skb_queue_head_init()
> to be consistent.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
