From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netem: fix dequeue
Date: Sun, 19 Feb 2012 19:00:03 -0500 (EST)
Message-ID: <20120219.190003.460010241580144655.davem@davemloft.net>
References: <1329373705.5646.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40643 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab2BTAAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 19:00:06 -0500
In-Reply-To: <1329373705.5646.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Feb 2012 07:28:25 +0100

> commit 50612537e9 (netem: fix classful handling) added two errors in
> netem_dequeue() 
> 
> 1) After checking skb at the head of tfifo queue for time constraints,
>    it dequeues tail skb, thus adding unwanted reordering.
> 
> 2) qdisc stats are updated twice per packet
>    (one when packet dequeued from tfifo, once when delivered)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
