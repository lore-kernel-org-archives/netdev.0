From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [NET-NEXT PATCH] e100: fix dma error in direction for mapping
Date: Mon, 17 Nov 2008 10:53:54 +0000
Message-ID: <20081117105354.GB2603@flint.arm.linux.org.uk>
References: <20081114235154.13239.11435.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:52254 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbYKQKyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 05:54:16 -0500
Content-Disposition: inline
In-Reply-To: <20081114235154.13239.11435.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2008 at 03:51:54PM -0800, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The e100 driver triggers BUG_ON(buf->direction != dir)
> by doing pci_map_single(..., PCI_DMA_BIDIRECTIONAL)
> and pci_dma_sync_single_for_device(..., PCI_DMA_TODEVICE).
> 
> Changing the DMA direction, especially with dmabounce will result
> in unexpected behaviour.
> 
> Reported-by: Anders Grafstrom <grfstrm@users.sourceforge.net>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Russell King <linux@arm.linux.org.uk>

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
