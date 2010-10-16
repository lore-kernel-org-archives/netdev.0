From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib: avoid false sharing on fib_table_hash
Date: Sat, 16 Oct 2010 11:56:10 -0700 (PDT)
Message-ID: <20101016.115610.48524281.davem@davemloft.net>
References: <1286994123.3876.1137.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35260
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879Ab0JPSzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:55:47 -0400
In-Reply-To: <1286994123.3876.1137.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Oct 2010 20:22:03 +0200

> While doing profile analysis, I found fib_hash_table was sometime in a
> cache line shared by a possibly often written kernel structure.
> 
> (CONFIG_IP_ROUTE_MULTIPATH || !CONFIG_IPV6_MULTIPLE_TABLES)
> 
> It's hard to detect because not easily reproductible.
> 
> Make sure we allocate a full cache line to keep this shared in all cpus
> caches.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
