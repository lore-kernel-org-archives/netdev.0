From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: fix possible NULL deref in
 netem_dequeue()
Date: Wed, 03 Jul 2013 16:53:47 -0700 (PDT)
Message-ID: <20130703.165347.1410553793449942226.davem@davemloft.net>
References: <1372885454.4979.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932206Ab3GCXxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 19:53:48 -0400
In-Reply-To: <1372885454.4979.73.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 Jul 2013 14:04:14 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit aec0a40a6f7884 ("netem: use rb tree to implement the time queue")
> added a regression if a child qdisc is attached to netem, as we perform
> a NULL dereference.
> 
> Fix this by adding a temporary variable to cache
> netem_skb_cb(skb)->time_to_send.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
