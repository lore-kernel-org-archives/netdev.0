From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 09:15:59 -0700 (PDT)
Message-ID: <20120718.091559.174027971595420359.davem@davemloft.net>
References: <1342613334.2626.2504.camel@edumazet-glaptop>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6F93@saturn3.aculab.com>
	<1342620366.2626.2764.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	andrewmcgr@gmail.com, dave.taht@gmail.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001Ab2GRQQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:16:00 -0400
In-Reply-To: <1342620366.2626.2764.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 16:06:06 +0200

> [PATCH net-next v2] ipv6: add ipv6_addr_hash() helper
> 
> Introduce ipv6_addr_hash() helper doing a XOR on all bits
> of an IPv6 address, with an optimized x86_64 version.
> 
> Use it in flow dissector, as suggested by Andrew McGregor,
> to reduce hash collision probabilities in fq_codel (and other
> users of flow dissector)
> 
> Use it in ip6_tunnel.c and use more bit shuffling, as suggested
> by David Laight, as existing hash was ignoring most of them.
> 
> Use it in sunrpc and use more bit shuffling, using hash_32().
> 
> As cleanup, use it in net/ipv4/tcp_metrics.c
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrew McGregor <andrewmcgr@gmail.com>

Looks good, applied.
