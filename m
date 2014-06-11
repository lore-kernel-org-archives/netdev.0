From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] farsync: Fix confusion about DMA address
 and buffer offset types
Date: Wed, 11 Jun 2014 00:45:53 -0700 (PDT)
Message-ID: <20140611.004553.333169592369134204.davem@davemloft.net>
References: <1402267774.23860.44.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kevin.curtis@farsite.co.uk
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbaFKHpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:45:54 -0400
In-Reply-To: <1402267774.23860.44.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 08 Jun 2014 23:49:34 +0100

> Use dma_addr_t for DMA address parameters and u32 for shared memory
> offset parameters.
> 
> Do not assume that dma_addr_t is the same as unsigned long; it will
> not be in PAE configurations.  Truncate DMA addresses to 32 bits when
> printing them.  This is OK because the DMA mask for this device is
> 32-bit (per default).
> 
> Also rename the DMA address parameters from 'skb' to 'dma'.
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied, thanks.
