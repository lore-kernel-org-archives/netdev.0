From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: fix TCP early demux
Date: Mon, 06 Aug 2012 13:33:44 -0700 (PDT)
Message-ID: <20120806.133344.682194503358687538.davem@davemloft.net>
References: <1344265773.26674.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756343Ab2HFUdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:33:44 -0400
In-Reply-To: <1344265773.26674.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Aug 2012 17:09:33 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> IPv6 needs a cookie in dst_check() call.
> 
> We need to add rx_dst_cookie and provide a family independent
> sk_rx_dst_set(sk, skb) method to properly support IPv6 TCP early demux.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.

> ---
> Note: we could group sk_rx_dst/rx_dst_ifindex/rx_dst_cookie
> in same cache line (in sk)

I don't think this is necessary, for now.
