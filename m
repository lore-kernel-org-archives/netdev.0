From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] mlx4_en: fix skb truesize underestimation
Date: Thu, 20 Oct 2011 04:55:53 -0400 (EDT)
Message-ID: <20111020.045553.251058108062947773.davem@davemloft.net>
References: <1318932782.2657.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1319086192.8416.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.co.il
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487Ab1JTI4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 04:56:00 -0400
In-Reply-To: <1319086192.8416.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 06:49:52 +0200

> skb->truesize must account for allocated memory, not the used part of
> it. Doing this work is important to avoid unexpected OOM situations.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
> V2: respin after recent patches

Applied, thanks Eric.
