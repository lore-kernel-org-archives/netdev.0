From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: introduce skb_try_coalesce()
Date: Sat, 19 May 2012 18:35:45 -0400 (EDT)
Message-ID: <20120519.183545.964398493609844274.davem@davemloft.net>
References: <1337432522.7029.194.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905Ab2ESWft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 18:35:49 -0400
In-Reply-To: <1337432522.7029.194.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 15:02:02 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Move tcp_try_coalesce() protocol independent part to 
> skb_try_coalesce().
> 
> skb_try_coalesce() can be used in IPv4 defrag and IPv6 reassembly,
> to build optimized skbs (less sk_buff, and possibly less 'headers')
> 
> skb_try_coalesce() is zero copy, unless the copy can fit in destination
> header (its a rare case)
> 
> kfree_skb_partial() is also moved to net/core/skbuff.c and exported,
> because IPv6 will need it in patch (ipv6: use skb coalescing in
> reassembly).
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
