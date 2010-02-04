From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: Fix ixgbe_tx_map error path
Date: Wed, 03 Feb 2010 19:17:26 -0800 (PST)
Message-ID: <20100203.191726.190578844.davem@davemloft.net>
References: <20100203231224.15352.27988.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, anton@samba.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753577Ab0BDDRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:17:13 -0500
In-Reply-To: <20100203231224.15352.27988.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 15:12:51 -0800

> From: Anton Blanchard <anton@samba.org>
> 
> Commit e5a43549f7a58509a91b299a51337d386697b92c (ixgbe: remove
> skb_dma_map/unmap calls from driver) looks to have introduced a bug in
> ixgbe_tx_map. If we get an error from a PCI DMA call, we loop backwards
> through count until it becomes -1 and return that.
> 
> The caller of ixgbe_tx_map expects 0 on error, so return that instead.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
