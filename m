From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_choke: use skb_header_pointer()
Date: Tue, 08 Nov 2011 17:04:58 -0500 (EST)
Message-ID: <20111108.170458.854828403298652075.davem@davemloft.net>
References: <1320785104.26025.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab1KHWFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 17:05:03 -0500
In-Reply-To: <1320785104.26025.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Nov 2011 21:45:04 +0100

> Remove the assumption that skb_get_rxhash() makes IP header and ports
> linear, and use skb_header_pointer() instead in choke_match_flow()
> 
> This permits __skb_get_rxhash() to use skb_header_pointer() eventually.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
