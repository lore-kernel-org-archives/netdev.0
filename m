From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 2 May 2007 23:48:58 +0100
Message-ID: <20070502224858.GA2363@infradead.org>
References: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com> <4638AE42.5000908@garzik.org> <1178130232.4820.62.camel@dell> <4638D775.3010905@garzik.org> <1178136161.4820.91.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44044 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767149AbXEBWtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 18:49:13 -0400
Content-Disposition: inline
In-Reply-To: <1178136161.4820.91.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2007 at 01:02:41PM -0700, Michael Chan wrote:
> Let's say I have a 32-bit card that cannot do dual address cycle on a
> 64-bit dma_addr_t system without IOMMU.  If CONFIG_HIGHMEM is not set,
> wouldn't the device get > 32-bit DMA addresses that it cannot handle?

It needs to set it's dma mask to 32bits and the upper layers (net, block)
will do the bouncing for it.  

