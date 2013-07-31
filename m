From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_orphan() changes
Date: Wed, 31 Jul 2013 15:24:58 -0700 (PDT)
Message-ID: <20130731.152458.92056892741307118.davem@davemloft.net>
References: <1375225875.10515.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760877Ab3GaWY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 18:24:59 -0400
In-Reply-To: <1375225875.10515.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Jul 2013 16:11:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> It is illegal to set skb->sk without corresponding destructor.
> 
> Its therefore safe for skb_orphan() to not clear skb->sk if
> skb->destructor is not set.
> 
> Also avoid clearing skb->destructor if already NULL.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, but personally I would have considered adding an
else clause checking BUG_ON(skb->sk), or are you not so
confident in your assertion? :-)
