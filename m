From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 4/5] e1000: return PCI_ERS_RESULT_DISCONNECT on
 permanent error
Date: Tue, 30 Jun 2009 19:53:58 -0700 (PDT)
Message-ID: <20090630.195358.184609131.davem@davemloft.net>
References: <20090630224515.17771.76848.stgit@localhost.localdomain>
	<20090630224612.17771.38476.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, adetsch@br.ibm.com,
	mmlnx@us.ibm.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758828AbZGACxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:53:53 -0400
In-Reply-To: <20090630224612.17771.38476.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Jun 2009 15:46:13 -0700

> From: Andre Detsch <adetsch@br.ibm.com>
> 
> PCI drivers that implement the io_error_detected callback
> should return PCI_ERS_RESULT_DISCONNECT if the state
> passed in is pci_channel_io_perm_failure.  This state is
> not checked in many of the network drivers.
> 
> The patch fixes the omission in the e1000 driver.
> 
> Based on Mike Mason's similar patch for e1000e.
> 
> Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
> CC: Mike Mason <mmlnx@us.ibm.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
