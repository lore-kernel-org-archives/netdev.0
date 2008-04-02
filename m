From: Chuck Ebbert <cebbert@redhat.com>
Subject: [patch] NET: remove support for Davicom 9102 from the Tulip driver
Date: Wed, 02 Apr 2008 18:46:57 -0400
Message-ID: <47F40CE1.2080708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757891AbYDBWrC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 18:47:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NET: remove support for Davicom 9102 from the Tulip driver

We have two reports that agree the tulip driver doesn't work for
the Davicom 9102 (PCI id 1282:9102). The dmfe driver does work
and also claims the same PCI ID.

https://bugzilla.redhat.com/show_bug.cgi?id=277731
https://bugzilla.redhat.com/show_bug.cgi?id=236928

Signed-off-by: Chuck Ebbert <cebbert@redhat.com>

---
 drivers/net/tulip/tulip_core.c |    1 -
 1 file changed, 1 deletion(-)

--- linux-2.6.24.noarch.orig/drivers/net/tulip/tulip_core.c
+++ linux-2.6.24.noarch/drivers/net/tulip/tulip_core.c
@@ -231,7 +231,6 @@ static struct pci_device_id tulip_pci_tb
 	{ 0x11F6, 0x9881, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMPEX9881 },
 	{ 0x8086, 0x0039, PCI_ANY_ID, PCI_ANY_ID, 0, 0, I21145 },
 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
-	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
 	{ 0x1113, 0x1216, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x1113, 0x1217, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98715 },
 	{ 0x1113, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
