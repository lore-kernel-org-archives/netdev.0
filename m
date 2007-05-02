From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 12:40:00 -0700 (PDT)
Message-ID: <20070502.124000.116378720.davem@davemloft.net>
References: <20070502.001243.70193466.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39607
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1766786AbXEBTkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 15:40:00 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 2 May 2007 08:23:40 -0700

> A non-IOMMU system using 64-bit dma_addr_t will always set
> CONFIG_HIGHMEM, right?

Nope, IA-64 is at least one example.

IA-64 has both IOMMU and non-IOMMU configurations, and
never sets HIGHMEM.
