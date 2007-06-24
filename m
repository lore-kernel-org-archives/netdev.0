From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: [CORE] Re-enable irqs before pushing pending DMA
 requests
Date: Sat, 23 Jun 2007 23:09:45 -0700 (PDT)
Message-ID: <20070623.230945.132856018.davem@davemloft.net>
References: <20070621163455.28160.35548.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54105
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753769AbXFXGJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 02:09:26 -0400
In-Reply-To: <20070621163455.28160.35548.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@intel.com>
Date: Thu, 21 Jun 2007 09:34:55 -0700

> This moves the local_irq_enable() call in net_rx_action() to before
> calling the CONFIG_NET_DMA's dma_async_memcpy_issue_pending() rather
> than after.  This shortens the irq disabled window and allows for DMA
> drivers that need to do their own irq hold.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>

Patch applied, thanks Shannon.
