From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] chelsio: add headroom in RX path
Date: Wed, 20 Mar 2013 13:29:52 -0400 (EDT)
Message-ID: <20130320.132952.1733436957649049289.davem@davemloft.net>
References: <1363797199.3333.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab3CTR3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:29:55 -0400
In-Reply-To: <1363797199.3333.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Mar 2013 09:33:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Drivers should reserve some headroom in skb used in receive path,
> to avoid future head reallocation.
> 
> One possible way to do that is to use dev_alloc_skb() instead
> of alloc_skb(), so that NET_SKB_PAD bytes are reserved.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
