From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add alloc_skb_with_frags() helper
Date: Fri, 19 Sep 2014 16:25:44 -0400 (EDT)
Message-ID: <20140919.162544.729091670312572114.davem@davemloft.net>
References: <1410954589.7106.227.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757671AbaISUZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:25:46 -0400
In-Reply-To: <1410954589.7106.227.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Sep 2014 04:49:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Extract from sock_alloc_send_pskb() code building skb with frags,
> so that we can reuse this in other contexts.
> 
> Intent is to use it from tcp_send_rcvq(), tcp_collapse(), ...
> 
> We also want to replace some skb_linearize() calls to a more reliable
> strategy in pathological cases where we need to reduce number of frags.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied.
