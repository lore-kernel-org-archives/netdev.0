From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gso_skb is now a list, needs a proper
 destructor
Date: Tue, 02 Sep 2014 15:06:04 -0700 (PDT)
Message-ID: <20140902.150604.267268114901700475.davem@davemloft.net>
References: <1409701903.26422.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbaICFGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 01:06:12 -0400
In-Reply-To: <1409701903.26422.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 02 Sep 2014 16:51:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> gso_skb can now be a list of skbs.
> 
> Qdisc destructors have to take care of it, or we can leak skbs.
> 
> Fixes: ce93718fb7cd ("net: Don't keep around original SKB when we software segment GSO frames.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
