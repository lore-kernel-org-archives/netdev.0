From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] farsync: Fix confusion about DMA address and
 buffer offset types
Date: Tue, 20 Dec 2011 23:46:56 -0500 (EST)
Message-ID: <20111220.234656.658595607282312696.davem@davemloft.net>
References: <1324430940.2844.144.camel@deadeye>
	<1324431172.2844.147.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevin.curtis@farsite.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503Ab1LUErK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 23:47:10 -0500
In-Reply-To: <1324431172.2844.147.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 21 Dec 2011 01:32:52 +0000

> -	dbg(DBG_RX, "In fst_rx_dma %lx %lx %d\n",
> -	    (unsigned long) skb, (unsigned long) mem, len);
> +	dbg(DBG_RX, "In fst_rx_dma %x %x %d\n", (u32)skb, mem, len);

This is more appropriately fixed by using "%p" instead of casting
to a 32-bit int.
