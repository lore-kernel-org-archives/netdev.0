From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgb: call pci_disable_device in ixgb_remove
Date: Thu, 28 Oct 2010 10:19:57 -0700 (PDT)
Message-ID: <20101028.101957.71111430.davem@davemloft.net>
References: <20101028105949.27748.82780.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bhutchings@solarflare.com, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45542
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932442Ab0J1RTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:19:33 -0400
In-Reply-To: <20101028105949.27748.82780.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 28 Oct 2010 03:59:49 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> ixgb fails to work after reload on recent kernels:
> 
> rmmod ixgb (dev->current_state = PCI_UNKNOWN)
> modprobe ixgb (pci_enable_device will bail leaving current_state to PCI_UNKNOWN)
> ifup eth0
> do_IRQ: 2.82 No irq handler for vector (irq -1)
> 
> The issue was exposed by commit fcd097f31a6ee207cc0c3da9cccd2a86d4334785
> PCI: MSI: Remove unsafe and unnecessary hardware access
> 
> which avoids HW writes for power states != PCI_D0
> 
> CC: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
