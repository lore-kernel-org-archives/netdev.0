From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv6: Fix IPsec slowpath fragmentation problem
Date: Tue, 18 Oct 2011 23:53:21 -0400 (EDT)
Message-ID: <20111018.235321.652135405877211986.davem@davemloft.net>
References: <20111011114251.GH1830@secunet.com>
	<20111011114333.GI1830@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab1JSDx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:53:27 -0400
In-Reply-To: <20111011114333.GI1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 11 Oct 2011 13:43:33 +0200

> ip6_append_data() builds packets based on the mtu from dst_mtu(rt->dst.path).
> On IPsec the effective mtu is lower because we need to add the protocol
> headers and trailers later when we do the IPsec transformations. So after
> the IPsec transformations the packet might be too big, which leads to a
> slowpath fragmentation then. This patch fixes this by building the packets
> based on the lower IPsec mtu from dst_mtu(&rt->dst) and adapts the exthdr
> handling to this.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
