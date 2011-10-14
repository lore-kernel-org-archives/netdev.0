From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ftgmac100: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 22:25:50 -0400 (EDT)
Message-ID: <20111013.222550.2221506906969662746.davem@davemloft.net>
References: <1318541452.2533.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ratbert@faraday-tech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928Ab1JNC0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 22:26:19 -0400
In-Reply-To: <1318541452.2533.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 23:30:52 +0200

> ftgmac100 allocates a page per skb fragment. We must account
> PAGE_SIZE increments on skb->truesize, not the actual frag length.
> 
> If frame is under 64 bytes, page is freed, and truesize adjusted.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
