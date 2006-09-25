From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH]: e1000: Janitor: Use #defined values for literals
Date: Mon, 25 Sep 2006 17:30:50 -0500
Message-ID: <20060925223050.GC4518@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:49051 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751260AbWIYWbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 18:31:53 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8PMVqFY026904
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 18:31:52 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8PMVqGj273210
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 18:31:52 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8PMUpLi028715
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 18:30:52 -0400
To: Auke Kok <sofar@foo-projects.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Resending a minor janitorial patch from long ago that seems to have 
fallen through the cracks.  Its not in 2.6.18-git4 nor in 2.6.18-mm1.
Please apply and forward upstream.

--linas

[PATCH]: e1000: Janitor: Use #defined values for literals

Minor janitorial patch: use #defines for literal values.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/e1000/e1000_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.18-mm1/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.18-mm1.orig/drivers/net/e1000/e1000_main.c	2006-09-25 17:23:32.000000000 -0500
+++ linux-2.6.18-mm1/drivers/net/e1000/e1000_main.c	2006-09-25 17:23:51.000000000 -0500
@@ -4986,8 +4986,8 @@ static pci_ers_result_t e1000_io_slot_re
 	}
 	pci_set_master(pdev);
 
-	pci_enable_wake(pdev, 3, 0);
-	pci_enable_wake(pdev, 4, 0); /* 4 == D3 cold */
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	/* Perform card reset only on one instance of the card */
 	if (PCI_FUNC (pdev->devfn) != 0)
