From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 17:13:27 -0400 (EDT)
Message-ID: <20111013.171327.2301959362661101273.davem@davemloft.net>
References: <1318540290.2533.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122Ab1JMVNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 17:13:36 -0400
In-Reply-To: <1318540290.2533.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 23:11:30 +0200

> sky2 allocates a page per skb fragment. We must account
> PAGE_SIZE increments on skb->truesize, not the actual frag length.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
