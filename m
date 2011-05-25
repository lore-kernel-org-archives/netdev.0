From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_sfq: fix peek() implementation
Date: Wed, 25 May 2011 17:57:46 -0400 (EDT)
Message-ID: <20110525.175746.11477561727918573.davem@davemloft.net>
References: <1306334411.2820.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org,
	hawk@diku.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932523Ab1EYWBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 18:01:00 -0400
In-Reply-To: <1306334411.2820.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 May 2011 16:40:11 +0200

> Since commit eeaeb068f139 (sch_sfq: allow big packets and be fair),
> sfq_peek() can return a different skb that would be normally dequeued by
> sfq_dequeue() [ if current slot->allot is negative ]
> 
> Use generic qdisc_peek_dequeued() instead of custom implementation, to
> get consistent result.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable.
