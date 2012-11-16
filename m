From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: handle tcp_net_metrics_init() order-5 memory
 allocation failures
Date: Fri, 16 Nov 2012 13:37:11 -0500 (EST)
Message-ID: <20121116.133711.1809052219019793698.davem@davemloft.net>
References: <1353022864.10798.6.camel@edumazet-glaptop>
	<20121116.013940.813652515905883288.davem@davemloft.net>
	<1353079913.10798.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jln@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab2KPShN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 13:37:13 -0500
In-Reply-To: <1353079913.10798.31.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Nov 2012 07:31:53 -0800

> Well, we dont really know what the size needs to be, and your proposal
> reduces the size by a 4 factor, even for the initial namespace.
> 
> Julien report was about Chrome browser own netns, on a suspend/resume
> cycle (or something like that)
> 
> If size can influence behavior, we could try a vmalloc() if kmalloc()
> fails...

Agreed.

> [PATCH v3] tcp: handle tcp_net_metrics_init() order-5 memory allocation failures
> 
> order-5 allocations can fail with current kernels, we should
> try vmalloc() as well.
> 
> Reported-by: Julien Tinnes <jln@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks great, applied, thanks.
