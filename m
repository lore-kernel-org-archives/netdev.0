From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/pasemi: fix compiler warning
Date: Wed, 02 May 2012 20:53:12 -0400 (EDT)
Message-ID: <20120502.205312.1917428334537687075.davem@davemloft.net>
References: <20120503105146.83f0a4a074dafad0443b875d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, olof@lixom.net, netdev@pradeepdalvi.com,
	linuxppc-dev@lists.ozlabs.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263Ab2ECA5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:57:24 -0400
In-Reply-To: <20120503105146.83f0a4a074dafad0443b875d@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 3 May 2012 10:51:46 +1000

> Fix this compiler warning (on PowerPC) by not marking a parameter as
> const:
> 
> drivers/net/ethernet/pasemi/pasemi_mac.c: In function 'pasemi_mac_replenish_rx_ring':
> drivers/net/ethernet/pasemi/pasemi_mac.c:646:3: warning: passing argument 1 of 'netdev_alloc_skb' discards qualifiers from pointer target type
> include/linux/skbuff.h:1706:31: note: expected 'struct net_device *' but argument is of type 'const struct net_device *'
> 
> Cc: Olof Johansson <olof@lixom.net>
> Cc: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks.
