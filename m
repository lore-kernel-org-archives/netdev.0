From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ftmac100: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 22:28:43 -0400 (EDT)
Message-ID: <20111013.222843.948173647135141130.davem@davemloft.net>
References: <1318540808.2533.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ratbert@faraday-tech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961Ab1JNC3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 22:29:02 -0400
In-Reply-To: <1318540808.2533.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 23:20:08 +0200

> ftmac100 allocates a page per skb fragment. We must account
> PAGE_SIZE increments on skb->truesize, not the actual frag length.
> 
> If frame is under 64 bytes, page is freed, so increase truesize only for
> bigger frames.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
