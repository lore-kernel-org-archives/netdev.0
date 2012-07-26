From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] pch_gbe: add extra clean tx
Date: Thu, 26 Jul 2012 14:31:36 -0700 (PDT)
Message-ID: <20120726.143136.495599687146212368.davem@davemloft.net>
References: <20120726160011.GC10287@telcoserv5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andycress@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594Ab2GZVbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:31:37 -0400
In-Reply-To: <20120726160011.GC10287@telcoserv5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Cress <andycress@gmail.com>
Date: Thu, 26 Jul 2012 12:00:11 -0400

> This adds extra cleaning to the pch_gbe_clean_tx routine to avoid 
> transmit timeouts on some BCM PHYs that have different timing.
> Also update the DRV_VERSION to 1.01, and show it.
> 
> Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

Applied.

 ....
> +		if (unused < 8) {  /* tx queue nearly full */
> +			pr_debug("clean_tx: transmit queue warning (%x,%x) unused=%d\n",
> +				tx_ring->next_to_clean,tx_ring->next_to_use,unused);
> +		}
> +	   
   ^^^^^^^^^^

Trailing whitespace.

> +		for (j = 0; j < PCH_GBE_TX_WEIGHT; j++) 
                                                       ^^^

Likewise.

Clean this crap up before submitting patches formally, so I don't have
to.
