From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] e1000e: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 16:06:36 -0400 (EDT)
Message-ID: <20111013.160636.311798427612447760.davem@davemloft.net>
References: <1318529016.2393.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab1JMUGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 16:06:40 -0400
In-Reply-To: <1318529016.2393.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 20:03:36 +0200

> e1000e allocates a page per skb fragment. We must account
> PAGE_SIZE increments on skb->truesize, not the actual frag length.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
