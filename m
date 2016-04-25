From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: better drop monitoring in
 ip{6}_recv_error()
Date: Mon, 25 Apr 2016 15:50:59 -0400 (EDT)
Message-ID: <20160425.155059.305878326715889507.davem@davemloft.net>
References: <1461302852.7627.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933450AbcDYTvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:51:01 -0400
In-Reply-To: <1461302852.7627.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Apr 2016 22:27:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We should call consume_skb(skb) when skb is properly consumed,
> or kfree_skb(skb) when skb must be dropped in error case.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
