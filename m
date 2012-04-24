From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skb_free_datagram_locked() consumes skb
Date: Tue, 24 Apr 2012 00:40:27 -0400 (EDT)
Message-ID: <20120424.004027.1845402387967749095.davem@davemloft.net>
References: <1335168567.3293.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064Ab2DXEk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:40:29 -0400
In-Reply-To: <1335168567.3293.20.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Apr 2012 10:09:27 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> All skb_free_datagram_locked() callers consume skb, not drop it.
> Noticed on dropwatch session polluted by UDP false positives.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

For some call sites in sunrpc, it's not a consume.
