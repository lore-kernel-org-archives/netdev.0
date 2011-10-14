From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 22:26:24 -0400 (EDT)
Message-ID: <20111013.222624.2143779600231737304.davem@davemloft.net>
References: <1318541897.2533.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928Ab1JNC0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 22:26:47 -0400
In-Reply-To: <1318541897.2533.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 23:38:17 +0200

> vmxnet3 allocates a page per skb fragment. We must account
> PAGE_SIZE increments on skb->truesize, not the actual frag length.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
