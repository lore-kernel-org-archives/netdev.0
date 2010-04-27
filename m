From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/7] igb: convert igb from using PCI DMA
 functions to using DMA API functions
Date: Tue, 27 Apr 2010 16:30:16 -0700 (PDT)
Message-ID: <20100427.163016.218073444.davem@davemloft.net>
References: <20100427230836.26173.59671.stgit@localhost.localdomain>
	<20100427230923.26173.83374.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51396
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753876Ab0D0XaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:30:10 -0400
In-Reply-To: <20100427230923.26173.83374.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 16:09:25 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch makes it so that igb now uses the DMA API functions instead of
> the PCI API functions.  To do this the pci_dev pointer that was in the
> rings has been replaced with a device pointer, and as a result all
> references to [tr]x_ring->pdev have been replaced with [tr]x_ring->dev.
> 
> This patch is based of of work originally done by Nicholas Nunley.
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
