From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] solos-pci: fix double-free of TX skb in DMA mode
Date: Wed, 12 Dec 2012 00:23:45 -0500 (EST)
Message-ID: <20121212.002345.2154152659215725592.davem@davemloft.net>
References: <1355273834.23544.37.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nathan@traverse.com.au
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2LLFXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 00:23:46 -0500
In-Reply-To: <1355273834.23544.37.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 12 Dec 2012 00:57:14 +0000

> We weren't clearing card->tx_skb[port] when processing the TX done interrupt.
> If there wasn't another skb ready to transmit immediately, this led to a
> double-free because we'd free it *again* next time we did have a packet to
> send.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Cc: stable@kernel.org

Acked-by: David S. Miller <davem@davemloft.net>
