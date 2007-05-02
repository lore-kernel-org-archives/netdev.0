From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 16:30:36 -0400
Message-ID: <4638F4EC.3000705@garzik.org>
References: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com> <4638AE42.5000908@garzik.org> <1178130232.4820.62.camel@dell> <4638D775.3010905@garzik.org> <1178136161.4820.91.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33533 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766991AbXEBUak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 16:30:40 -0400
In-Reply-To: <1178136161.4820.91.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> If CONFIG_HIGHMEM is not set,
> wouldn't the device get > 32-bit DMA addresses that it cannot handle?

No -- presuming your PCI device's DMA mask is set correctly.


> I know that there are 64-bit systems without IOMMUs.  That's why we need
[...]
> needed or not.  These systems without IOMMU must support 32-bit only
> cards, right?  How do they do that if they are not using CONFIG_HIGHMEM?

pci_set_dma_mask()

	Jeff


