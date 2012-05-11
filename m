From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: avoid disabling sriov while VFs are
 assigned
Date: Thu, 10 May 2012 23:35:20 -0400 (EDT)
Message-ID: <20120510.233520.938899377509037311.davem@davemloft.net>
References: <647fcd25-8a85-4d63-a1ef-8b867832c2c7@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932408Ab2EKDfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:35:24 -0400
In-Reply-To: <647fcd25-8a85-4d63-a1ef-8b867832c2c7@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 9 May 2012 11:11:24 +0530

> Calling pci_disable_sriov() while VFs are assigned to VMs causes
> kernel panic. This patch uses PCI_DEV_FLAGS_ASSIGNED bit state of the
> VF's pci_dev to avoid this. Also, the unconditional function reset cmd
> issued on a PF probe can delete the VF configuration for the
> previously enabled VFs. A scratchpad register is now used to issue a
> function reset only when needed (i.e., in a crash dump scenario.)
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
