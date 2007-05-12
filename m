From: olof@lixom.net
Subject: [patch 3/4] pasemi_mac: Terminate PCI ID list
Date: Sat, 12 May 2007 14:57:36 -0500
Message-ID: <20070512195736.GD15137@lixom.net>
References: <20070512193929.193104000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46374 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757220AbXELTyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2007 15:54:53 -0400
Content-Disposition: inline; filename=pasemi_mac-terminate-device-list
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This caused some very interesting behaviour depending on what happened to
be built at the same time. Add terminating empty entry to the list of IDs.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -1211,6 +1211,7 @@ static void __devexit pasemi_mac_remove(
 static struct pci_device_id pasemi_mac_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa005) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa006) },
+	{ },
 };
 
 MODULE_DEVICE_TABLE(pci, pasemi_mac_pci_tbl);

--
