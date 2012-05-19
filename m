From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tg3: use netdev_alloc_frag() API
Date: Sat, 19 May 2012 04:03:05 -0400 (EDT)
Message-ID: <20120519.040305.1916325697646915932.davem@davemloft.net>
References: <1337411749.7029.77.camel@edumazet-glaptop>
	<1337412819.7029.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134Ab2ESIDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 04:03:08 -0400
In-Reply-To: <1337412819.7029.81.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 09:33:39 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Update our reference driver to use netdev_alloc_frag() API instead of
> the temporary custom allocator I introduced in commit 8d4057a938
> (tg3: provide frags as skb head)
> 
> This removes the memory leak we had, since we could leak one page at
> device dismantle.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
