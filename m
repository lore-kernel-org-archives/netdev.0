From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] solos-pci: Fix DMA support
Date: Thu, 24 May 2012 16:21:10 -0400 (EDT)
Message-ID: <20120524.162110.1171594268360411622.davem@davemloft.net>
References: <1337871507.26314.132.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nathan@traverse.com.au
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab2EXUYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 16:24:30 -0400
In-Reply-To: <1337871507.26314.132.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 24 May 2012 15:58:27 +0100

> DMA support has finally made its way to the top of the TODO list, having
> realised that a Geode using MMIO can't keep up with two ADSL2+ lines
> each running at 21Mb/s.
> 
> This patch fixes a couple of bugs in the DMA support in the driver, so
> once the corresponding FPGA update is complete and tested everything
> should work properly.
> 
> We weren't storing the currently-transmitting skb, so we were never
> unmapping it and never freeing/popping it when the TX was done.
> And the addition of pci_set_master() is fairly self-explanatory.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied.
