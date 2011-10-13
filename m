From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ixgbe: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 16:06:28 -0400 (EDT)
Message-ID: <20111013.160628.935845177513244339.davem@davemloft.net>
References: <1318528781.2393.59.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452Ab1JMUGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 16:06:32 -0400
In-Reply-To: <1318528781.2393.59.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 19:59:41 +0200

> ixgbe allocates half a page per skb fragment. We must account
> PAGE_SIZE/2 increments on skb->truesize, not the actual frag length.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
