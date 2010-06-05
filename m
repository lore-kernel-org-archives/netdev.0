From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Sat, 05 Jun 2010 03:04:07 -0700 (PDT)
Message-ID: <20100605.030407.191387535.davem@davemloft.net>
References: <20100603130235.c372b38f.akpm@linux-foundation.org>
	<1275599603.2533.58.camel@edumazet-laptop>
	<1275601036.2533.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39711
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932654Ab0FEKD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 06:03:58 -0400
In-Reply-To: <1275601036.2533.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 23:37:16 +0200

> [PATCH] ipv6: avoid high order allocations
> 
> With mtu=9000, mld_newpack() use order-2 GFP_ATOMIC allocations, that
> are very unreliable, on machines where PAGE_SIZE=4K
> 
> Limit allocated skbs to be at most one page. (order-0 allocations)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This looks perfectly fine to me, except I had to change
min(...) to min_t(int, ...) to avoid a compile warning.

Thanks Eric!
