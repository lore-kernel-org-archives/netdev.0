From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] ipv4: use skb coalescing in
 defragmentation
Date: Sat, 19 May 2012 18:35:51 -0400 (EDT)
Message-ID: <20120519.183551.2253334708875962938.davem@davemloft.net>
References: <1337432540.7029.195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757809Ab2ESWfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 18:35:53 -0400
In-Reply-To: <1337432540.7029.195.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 15:02:20 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ip_frag_reasm() can use skb_try_coalesce() to build optimized skb,
> reducing memory used by them (truesize), and reducing number of cache
> line misses and overhead for the consumer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
