From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] ipv6: use skb coalescing in reassembly
Date: Sat, 19 May 2012 18:35:56 -0400 (EDT)
Message-ID: <20120519.183556.1085711138074171029.davem@davemloft.net>
References: <1337432555.7029.196.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757844Ab2ESWf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 18:35:58 -0400
In-Reply-To: <1337432555.7029.196.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 15:02:35 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ip6_frag_reasm() can use skb_try_coalesce() to build optimized skb,
> reducing memory used by them (truesize), and reducing number of cache
> line misses and overhead for the consumer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
