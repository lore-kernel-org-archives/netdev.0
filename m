From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 4/4] ixgbe: fix unmap length bug
Date: Tue, 30 Jun 2009 19:50:48 -0700 (PDT)
Message-ID: <20090630.195048.267762907.davem@davemloft.net>
References: <20090630214349.17464.25370.stgit@localhost.localdomain>
	<20090630214456.17464.70554.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	jesse.brandeburg@intel.com, joerg.roedel@amd.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50717
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756283AbZGACum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:50:42 -0400
In-Reply-To: <20090630214456.17464.70554.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Jun 2009 14:44:56 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> This patch addresses three WARN_ON statements from DMA-API debug code
> 
> ixgbe is mapping more than it unmaps, reduce the length of the map call and
> remove the "used once" local variable.
> 
> found by Joerg Roedel <joerg.roedel@amd.com> in 2.6.30, so is a candidate
> for -stable.
> 
> in addition, fix missing ->dma = 0 after unmap to prevent double free with
> pci_unmap_single
> 
> and lastly, don't unmap (half) pages that aren't mapped.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Joerg Roedel <joerg.roedel@amd.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
