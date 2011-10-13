From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 16:06:11 -0400 (EDT)
Message-ID: <20111013.160611.176337258525308966.davem@davemloft.net>
References: <1318528219.2393.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab1JMUGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 16:06:16 -0400
In-Reply-To: <1318528219.2393.52.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 19:50:19 +0200

> bnx2 allocates a full page per fragment. We must account PAGE_SIZE
> increments on skb->truesize, not the actual frag length.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
