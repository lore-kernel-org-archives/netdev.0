From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Add __dev_forward_skb
Date: Sun, 20 Apr 2014 18:19:56 -0400 (EDT)
Message-ID: <20140420.181956.26393022875302868.davem@davemloft.net>
References: <20140407075347.GA26461@gondor.apana.org.au>
	<20140417054502.GA23959@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbaDTWT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 18:19:58 -0400
In-Reply-To: <20140417054502.GA23959@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 17 Apr 2014 13:45:03 +0800

> This patch adds the helper __dev_forward_skb which is identical to
> dev_forward_skb except that it doesn't actually inject the skb into
> the stack.  This is useful where we wish to have finer control over
> how the packet is injected, e.g., via netif_rx_ni or netif_receive_skb.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
