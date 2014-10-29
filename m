From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_segment() should preserve
 backpressure
Date: Wed, 29 Oct 2014 14:47:36 -0400 (EDT)
Message-ID: <20141029.144736.1849092497823226235.davem@davemloft.net>
References: <1414422089.16231.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<1414424388.16231.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<1414431051.16231.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: makita.toshiaki@lab.ntt.co.jp, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbaJ2Srj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 14:47:39 -0400
In-Reply-To: <1414431051.16231.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Oct 2014 10:30:51 -0700

> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> 
> This patch generalizes commit d6a4a1041176 ("tcp: GSO should be TSQ
> friendly") to protocols using skb_set_owner_w()
> 
> TCP uses its own destructor (tcp_wfree) and needs a more complex scheme
> as explained in commit 6ff50cd55545 ("tcp: gso: do not generate out of
> order packets")
> 
> This allows UDP sockets using UFO to get proper backpressure,
> thus avoiding qdisc drops and excessive cpu usage.
> 
> Here are performance test results (macvlan on vlan):
 ...
> [edumazet] Rewrote patch and changelog.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
