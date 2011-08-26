From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: sfb: optimize enqueue on full queue
Date: Fri, 26 Aug 2011 12:53:03 -0400 (EDT)
Message-ID: <20110826.125303.417595055132273367.davem@davemloft.net>
References: <1314289292.2387.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab1HZQxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:53:07 -0400
In-Reply-To: <1314289292.2387.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 25 Aug 2011 18:21:32 +0200

> In case SFB queue is full (hard limit reached), there is no point
> spending time to compute hash and maximum qlen/p_mark.
> 
> We instead just early drop packet.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
