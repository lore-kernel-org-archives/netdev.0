From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Fix IPsec slowpath fragmentation problem
Date: Mon, 27 Jun 2011 20:39:54 -0700 (PDT)
Message-ID: <20110627.203954.64191314708724007.davem@davemloft.net>
References: <20110622110437.GG6489@secunet.com>
	<20110622110537.GH6489@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756452Ab1F1DkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 23:40:01 -0400
In-Reply-To: <20110622110537.GH6489@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 22 Jun 2011 13:05:37 +0200

> ip_append_data() builds packets based on the mtu from dst_mtu(rt->dst.path).
> On IPsec the effective mtu is lower because we need to add the protocol
> headers and trailers later when we do the IPsec transformations. So after
> the IPsec transformations the packet might be too big, which leads to a
> slowpath fragmentation then. This patch fixes this by building the packets
> based on the lower IPsec mtu from dst_mtu(&rt->dst) and adapts the exthdr
> handling to this.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
