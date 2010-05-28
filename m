From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xt_tee: use skb_dst_drop()
Date: Fri, 28 May 2010 03:41:30 -0700 (PDT)
Message-ID: <20100528.034130.15258779.davem@davemloft.net>
References: <1275038698.2650.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jengelh@medozas.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757504Ab0E1KlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 06:41:19 -0400
In-Reply-To: <1275038698.2650.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 May 2010 11:24:58 +0200

> After commit 7fee226a (net: add a noref bit on skb dst), its wrong to
> use : dst_release(skb_dst(skb)), since we could decrement a refcount
> while skb dst was not refcounted.
> 
> We should use skb_dst_drop(skb) instead.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
