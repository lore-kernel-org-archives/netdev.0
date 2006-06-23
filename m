From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH]: e1000: Janitor: Use #defined values for literals
Date: Fri, 23 Jun 2006 11:36:24 -0500
Message-ID: <20060623163624.GM8866@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:28387 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751754AbWFWQg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 12:36:27 -0400
To: netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	"Zhang, Yanmin" <yanmin.zhang@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Minor janitorial patch: use #defines for literal values.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/e1000/e1000_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.17-rc6-mm2/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.17-rc6-mm2.orig/drivers/net/e1000/e1000_main.c	2006-06-13 18:13:30.000000000 -0500
+++ linux-2.6.17-rc6-mm2/drivers/net/e1000/e1000_main.c	2006-06-23 11:27:47.000000000 -0500
@@ -4663,8 +4663,8 @@ static pci_ers_result_t e1000_io_slot_re
 	}
 	pci_set_master(pdev);
 
-	pci_enable_wake(pdev, 3, 0);
-	pci_enable_wake(pdev, 4, 0); /* 4 == D3 cold */
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	/* Perform card reset only on one instance of the card */
 	if (PCI_FUNC (pdev->devfn) != 0)
