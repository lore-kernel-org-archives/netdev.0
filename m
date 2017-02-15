From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: aquantia: switch to
 pci_alloc_irq_vectors
Date: Wed, 15 Feb 2017 13:05:49 -0500 (EST)
Message-ID: <20170215.130549.1600064342285559762.davem@davemloft.net>
References: <20170215073847.1030-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vomlehn@texas.net, netdev@vger.kernel.org
To: hch@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751694AbdBOSFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 13:05:51 -0500
In-Reply-To: <20170215073847.1030-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>
Date: Wed, 15 Feb 2017 08:38:47 +0100

> pci_enable_msix has been long deprecated, but this driver adds a new
> instance.  Convert it to pci_alloc_irq_vectors so that no new instance
> of the deprecated function reaches mainline.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Applied to net-next, thanks.
