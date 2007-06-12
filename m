From: Ayyappan.Veeraiyan@intel.com
Subject: [ANNOUNCE] new driver ixgbe for Intel(R) 10GbE PCI Express adapters.
Date: Tue, 12 Jun 2007 16:44:23 -0700
Message-ID: <20070612234417.5102.29147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, ayyappan.veeraiyan@intel.com,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26323 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753857AbXFLXoa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 19:44:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All,

We are pleased to release the new driver "ixgbe" for Intel(R) 82598
based 10GbE PCI Express adapters. The 82598 silicon and the adapters will be
released soon.
	
Please find the full driver as a patch to latest linus-2.6 tree here:
    git-pull git://lost.foo-projects.org/~aveerani/git/linux-2.6 ixgbe

Also, I am posting the driver patch in the followup mail. 

Short introduction on the "ixgbe" driver and 82598 silicon:

The 82598 (PCI Express) silicon's architecture and SW interface
is vastly different from legacy 82597 (PCI-X device). The register
offsets and the bit definitions are very different from 82597. The
EEPROM/FLASH, SERDES interface for external PHY and other interfaces
are also different. 82598 has new Tx and Rx descriptor interfaces
(adavanced descriptors) to support packet/header split Rx feauture and
Rx packet steering (based on 5 tuples or MAC addresses). It supports
list of new features like MSI-X, Multiple Rx and Tx queues, TSO for
IPv6. Because of all these differences, we had to write a new driver
for 82598 and the new driver is lot cleaner with no 82597 errata
workarounds in the hot path.

This driver has been tested extensively for the last couple of months
in our labs.

Please review and provide comments.

Apart from implementing the community feedback, here is the list of
things in TODO list...

1. Add suspend/resume support.
2. Rewrite the driver handling of LLTX logic. Will post a patch very
   soon for review.
3. Add PCI error handler support.

thanks,
Ayyappan
