From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: use netdev_alloc_frag() API
Date: Sat, 19 May 2012 03:19:14 -0400 (EDT)
Message-ID: <20120519.031914.1744866102736414778.davem@davemloft.net>
References: <1337411749.7029.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab2ESHTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 03:19:18 -0400
In-Reply-To: <1337411749.7029.77.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 09:15:49 +0200

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

Hmmm, doesn't apply cleanly to net-next for some reason:

[davem@drr net-next]$ git am --signoff net-next-tg3-use-netdev_alloc_frag-API.patch 
Applying: tg3: use netdev_alloc_frag() API
error: patch failed: drivers/net/ethernet/broadcom/tg3.c:5631
error: drivers/net/ethernet/broadcom/tg3.c: patch does not apply
Patch failed at 0001 tg3: use netdev_alloc_frag() API
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".
