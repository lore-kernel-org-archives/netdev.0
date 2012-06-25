From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: l2tp_eth: fix l2tp_eth_dev_xmit race
Date: Mon, 25 Jun 2012 16:31:16 -0700 (PDT)
Message-ID: <20120625.163116.2198126912459071838.davem@davemloft.net>
References: <1340621114.10893.29.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757632Ab2FYXbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:31:17 -0400
In-Reply-To: <1340621114.10893.29.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Jun 2012 12:45:14 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Its illegal to dereference skb after giving it to l2tp_xmit_skb()
> as it might be already freed/reused.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: James Chapman <jchapman@katalix.com>

Applied, thanks Eric.
