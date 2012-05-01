From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 net-next] tg3: provide frags as skb head
Date: Mon, 30 Apr 2012 21:48:16 -0400 (EDT)
Message-ID: <20120430.214816.1532282721850063056.davem@davemloft.net>
References: <1335522889.2775.231.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	therbert@google.com, ncardwell@google.com,
	bhutchings@solarflare.com, mcarlson@broadcom.com,
	jeffrey.t.kirsher@intel.com, mchan@broadcom.com,
	herbert@gondor.hengli.com.au, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757810Ab2EABsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:48:33 -0400
In-Reply-To: <1335522889.2775.231.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Apr 2012 12:34:49 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch converts tg3 driver, one of our reference drivers, to use new
> build_skb() api in frag mode.
> 
> Instead of using kmalloc() to allocate the memory block that will be
> used by build_skb() as skb->head, we use a page fragment.
> 
> This is a followup of patch "net: allow skb->head to be a page fragment"
> 
> This allows GRO, TCP coalescing, and splice() to be more efficient.
> 
> Incidentally, this also removes SLUB slow path contention in kfree()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
