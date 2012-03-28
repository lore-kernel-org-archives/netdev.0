From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] net/core: dev_forward_skb() should clear skb_iif
Date: Wed, 28 Mar 2012 04:46:14 -0400 (EDT)
Message-ID: <20120328.044614.1663135683027279533.davem@davemloft.net>
References: <20120328015544.GA11104@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011Ab2C1IqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 04:46:17 -0400
In-Reply-To: <20120328015544.GA11104@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 27 Mar 2012 21:55:44 -0400

> While investigating another bug, I found that the code on the incoming path
> in __netif_receive_skb will only set skb->skb_iif if it is already 0.  When
> dev_forward_skb() is used in the case of interfaces like veth, skb_iif may
> already have been set.  Making dev_forward_skb() cause the packet to look
> like a newly received packet would seem to the the correct behaviour here,
> as otherwise the wrong incoming interface can be reported for such a packet.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Applied.
