From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Mon, 16 Aug 2010 13:57:07 -0700 (PDT)
Message-ID: <20100816.135707.232921794.davem@davemloft.net>
References: <1281883637.2942.42.camel@edumazet-laptop>
	<20100816.123607.57459160.davem@davemloft.net>
	<1281990130.2487.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, peterz@infradead.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47925
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756712Ab0HPU4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 16:56:49 -0400
In-Reply-To: <1281990130.2487.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Aug 2010 22:22:10 +0200

> [PATCH] netfilter: {ip,ip6,arp}_tables: avoid lockdep false positive
> 
> After commit 24b36f019 (netfilter: {ip,ip6,arp}_tables: dont block
> bottom half more than necessary), lockdep can raise a warning
> because we attempt to lock a spinlock with BH enabled, while
> the same lock is usually locked by another cpu in a softirq context.
> 
> Disable again BH to avoid these lockdep warnings.
> 
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Diagnosed-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Peter Zijlstra <peterz@infradead.org>

Acked-by: David S. Miller <davem@davemloft.net>
