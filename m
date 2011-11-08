From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: better pcpu data alignment
Date: Tue, 08 Nov 2011 15:17:30 -0500 (EST)
Message-ID: <20111108.151730.2028643765538113036.davem@davemloft.net>
References: <1320484768.16609.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381Ab1KHURe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 15:17:34 -0500
In-Reply-To: <1320484768.16609.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 Nov 2011 10:19:28 +0100

> Tunnels can force an alignment of their percpu data to reduce number of
> cache lines used in fast path, or read in .ndo_get_stats()
> 
> percpu_alloc() is a very fine grained allocator, so any small hole will
> be used anyway.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
