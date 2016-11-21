From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: avoid one cache line miss in recvmsg()
Date: Mon, 21 Nov 2016 11:27:12 -0500 (EST)
Message-ID: <20161121.112712.1751786462749387402.davem@davemloft.net>
References: <1479518283.8455.312.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755012AbcKUQhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 11:37:05 -0500
In-Reply-To: <1479518283.8455.312.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Nov 2016 17:18:03 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> UDP_SKB_CB(skb)->partial_cov is located at offset 66 in skb,
> requesting a cold cache line being read in cpu cache.
> 
> We can avoid this cache line miss for UDP sockets,
> as partial_cov has a meaning only for UDPLite.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
