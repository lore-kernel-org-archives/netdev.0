From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 15:50:34 -0700 (PDT)
Message-ID: <20070502.155034.08679790.davem@davemloft.net>
References: <4638D775.3010905@garzik.org>
	<1178136161.4820.91.camel@dell>
	<20070502224858.GA2363@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jeff@garzik.org, netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767161AbXEBWud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 18:50:33 -0400
In-Reply-To: <20070502224858.GA2363@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 2 May 2007 23:48:58 +0100

> On Wed, May 02, 2007 at 01:02:41PM -0700, Michael Chan wrote:
> > Let's say I have a 32-bit card that cannot do dual address cycle on a
> > 64-bit dma_addr_t system without IOMMU.  If CONFIG_HIGHMEM is not set,
> > wouldn't the device get > 32-bit DMA addresses that it cannot handle?
> 
> It needs to set it's dma mask to 32bits and the upper layers (net, block)
> will do the bouncing for it.  

Not the case for networking, we rely upon the DMA API to take
care of things, which it does.
