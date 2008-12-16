From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] net: Add frag_list support to skb_segment
Date: Mon, 15 Dec 2008 23:27:19 -0800 (PST)
Message-ID: <20081215.232719.194297496.davem@davemloft.net>
References: <20081213013420.GA13549@gondor.apana.org.au>
	<E1LBJPb-0003YB-0e@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55683
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751443AbYLPH1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 02:27:18 -0500
In-Reply-To: <E1LBJPb-0003YB-0e@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 13 Dec 2008 12:35:19 +1100

> net: Add frag_list support to skb_segment
> 
> This patch adds limited support for handling frag_list packets in
> skb_segment.  The intention is to support GRO (Generic Receive Offload)
> packets which will be constructed by chaining normal packets using
> frag_list.
> 
> As such we require all frag_list members terminate on exact MSS
> boundaries.  This is checked using BUG_ON.
> 
> As there should only be one producer in the kernel of such packets,
> namely GRO, this requirement should not be difficult to maintain.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
