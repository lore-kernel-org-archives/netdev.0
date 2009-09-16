From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [Patch net-next]atl1e:fix 2.6.31-git4 -- ATL1E 0000:03:00.0:
	DMA-API: device driver frees DMA
Date: Wed, 16 Sep 2009 13:51:38 +0400
Message-ID: <20090916095138.GH5094@lenovo>
References: <12530821133392-git-send-email-jie.yang@atheros.com> <1253092251.11643.569.camel@desktop> <20090916.024759.51103835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dwalker@fifo99.com, jie.yang@atheros.com, miles.lane@gmail.com,
	chris.snook@gmail.com, jcliburn@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:34072 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbZIPJvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 05:51:38 -0400
Content-Disposition: inline
In-Reply-To: <20090916.024759.51103835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[David Miller - Wed, Sep 16, 2009 at 02:47:59AM -0700]
| From: Daniel Walker <dwalker@fifo99.com>
| Date: Wed, 16 Sep 2009 02:10:51 -0700
| 
| > On Wed, 2009-09-16 at 14:21 +0800, jie.yang@atheros.com wrote:
| >> -           pci_unmap_page(pdev, tx_buffer->dma,
| >> +           if (tx_buffer->flags & ATL1E_TX_PCIMAP_SINGLE)
| >> +               pci_unmap_single(pdev, tx_buffer->dma,
| >> +                   tx_buffer->length, PCI_DMA_TODEVICE);
| >> +           else if (tx_buffer->flags & ATL1E_TX_PCIMAP_PAGE)
| >> +               pci_unmap_page(pdev, tx_buffer->dma,
| > 
| > Could you run this through checkpatch, and fix any errors if find? It
| > looks like you uses spaces for tabs in the code above, maybe in the
| > other block too..
| > 
| 
| It's because of his email client, it corrupted the whole patch
| like that.

well, client seems to be

| X-Mailer: git-send-email 1.5.2.2

more probably the text editor is the reason.

	-- Cyrill
