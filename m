From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock: sock_dequeue_err_skb() needs hard irq safety
Date: Fri, 20 Feb 2015 15:53:22 -0500 (EST)
Message-ID: <20150220.155322.301911552130546662.davem@davemloft.net>
References: <1424267275.4942.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281AbbBTUxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:53:24 -0500
In-Reply-To: <1424267275.4942.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Feb 2015 05:47:55 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Non NAPI drivers can call skb_tstamp_tx() and then sock_queue_err_skb()
> from hard IRQ context.
> 
> Therefore, sock_dequeue_err_skb() needs to block hard irq or
> corruptions or hangs can happen.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 364a9e93243d1 ("sock: deduplicate errqueue dequeue")
> Fixes: cb820f8e4b7f7 ("net: Provide a generic socket error queue delivery method for Tx time stamps.")

Applied and queued up for -stable, thanks Eric.
