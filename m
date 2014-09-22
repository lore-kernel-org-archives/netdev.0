From: David Miller <davem@davemloft.net>
Subject: Re: Corrupt Network Packets -- 3.17-rc5/rc6
Date: Mon, 22 Sep 2014 15:07:36 -0400 (EDT)
Message-ID: <20140922.150736.400581155949686923.davem@davemloft.net>
References: <20140922.133831.220769383344675250.davem@davemloft.net>
	<201409221830.s8MIUbWS002990@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: clem@clem.clem-digital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbaIVTHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:07:38 -0400
In-Reply-To: <201409221830.s8MIUbWS002990@clem.clem-digital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pete Clements <clem@clem.clem-digital.net>
Date: Mon, 22 Sep 2014 14:30:36 -0400 (EDT)

> 
> Thanks. Does not patch. Code looks not to be in the rc6 that Linus
> put out. Guess there is more to come.  (This is what I believe is
> the segment in rc6 -- at line 2179.)
> 
> 	vp->tx_ring[entry].frag[i+1].addr =
> 		cpu_to_le32(skb_frag_dma_map(
> 		&VORTEX_PCI(vp)->dev,
> 		frag,
> 		frag->page_offset, frag->size, DMA_TO_DEVICE));

Just simply change the frag->page_offset argument to zero.
