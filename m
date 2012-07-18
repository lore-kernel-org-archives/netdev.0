From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 11:29:43 -0700 (PDT)
Message-ID: <20120718.112943.524170725976000575.davem@davemloft.net>
References: <1342620841.2626.2786.camel@edumazet-glaptop>
	<1342621670.2626.2818.camel@edumazet-glaptop>
	<1342635072.2626.3322.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, andrewmcgr@gmail.com,
	dave.taht@gmail.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab2GRS3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:29:44 -0400
In-Reply-To: <1342635072.2626.3322.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 20:11:12 +0200

> From: Eric Dumazet <edumazet@google.com>
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
> Use it in net/ipv6/addrconf.c, using hash_32() as well.
> 
> As a cleanup, use it in net/ipv4/tcp_metrics.c
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrew McGregor <andrewmcgr@gmail.com>

Applied, thanks.

> v4: net/ipv6/addrconf.c part, sorry again David

The more you test my routing cache removal patches, the
more you will be forgiven :-))))))
