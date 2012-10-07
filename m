From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: GRO should be ECN friendly
Date: Sun, 07 Oct 2012 14:45:31 -0400 (EDT)
Message-ID: <20121007.144531.707087734601338126.davem@davemloft.net>
References: <1349505810.21172.198.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902Ab2JGSpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 14:45:33 -0400
In-Reply-To: <1349505810.21172.198.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 06 Oct 2012 08:43:30 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> IPv4 side of the problem was addressed in commit a9e050f4e7f9d
> (net: tcp: GRO should be ECN friendly)
> 
> This patch does the same, but for IPv6 : A Traffic Class mismatch
> doesnt mean flows are different, but instead should force a flush
> of previous packets.
> 
> This patch removes artificial packet reordering problem.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Eric.
