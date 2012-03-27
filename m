From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net/core] dev_forward_skb() should clear skb_iif
Date: Tue, 27 Mar 2012 17:37:07 -0400 (EDT)
Message-ID: <20120327.173707.226441470555050908.davem@davemloft.net>
References: <20120327162920.GB2367@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab2C0Vm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 17:42:29 -0400
In-Reply-To: <20120327162920.GB2367@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 27 Mar 2012 12:29:20 -0400

> While investigating another bug, I found that the code on the incoming path
> in __netif_receive_skb will only set skb->skb_iif if it is already 0.  When
> dev_forward_skb() is used in the case of interfaces like veth, skb_iif may
> already have been set.  Making dev_forward_skb() cause the packet to look
> more like a newly received packet would seem to the the correct behaviour
> here, as otherwise the wrong incoming interface can be reported for such a
> packet.

Same problems as your ipv4 multicast patch, I'm not applying this.

You must learn how to properly submit your changes, otherwise I
guarentee all of your work will hit the bit bucket.
