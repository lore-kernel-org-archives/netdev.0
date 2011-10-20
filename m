From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igbvf: fix truesize underestimation
Date: Thu, 20 Oct 2011 17:42:26 -0400 (EDT)
Message-ID: <20111020.174226.1424871936693188167.davem@davemloft.net>
References: <1319138538.2854.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470Ab1JTVma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:42:30 -0400
In-Reply-To: <1319138538.2854.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 21:22:18 +0200

> igbvf allocates half a page per skb fragment. We must account
> PAGE_SIZE/2 increments on skb->truesize, not the actual frag length.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
