From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] b44: use dev_kfree_skb() in b44_tx()
Date: Mon, 04 Jul 2011 17:57:22 -0700 (PDT)
Message-ID: <20110704.175722.549994766636319487.davem@davemloft.net>
References: <1309794113.2247.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab1GEA50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 20:57:26 -0400
In-Reply-To: <1309794113.2247.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Jul 2011 17:41:53 +0200

> b44_tx() is run from softirq handler, it can use dev_kfree_skb() instead
> of dev_kfree_skb_irq()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
