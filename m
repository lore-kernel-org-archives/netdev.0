From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Replace dma/pci_alloc_coherent() calls
 with dma_zalloc_coherent()
Date: Sun, 07 Jun 2015 15:35:34 -0700 (PDT)
Message-ID: <20150607.153534.428168062355309988.davem@davemloft.net>
References: <1433498639-4749-1-git-send-email-sriharsha.basavapatna@avagotech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbbFGWff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 18:35:35 -0400
In-Reply-To: <1433498639-4749-1-git-send-email-sriharsha.basavapatna@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
Date: Fri,  5 Jun 2015 15:33:59 +0530

> There are several places in the driver (all in control paths) where
> coherent dma memory is being allocated using either dma_alloc_coherent()
> or the deprecated pci_alloc_consistent(). All these calls should be
> changed to use dma_zalloc_coherent() to avoid uninitialized fields in
> data structures backed by this memory.
> 
> Reported-by: Joerg Roedel <jroedel@suse.de>
> Tested-by: Joerg Roedel <jroedel@suse.de>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>

Applied and queued up for -stable, thanks.
