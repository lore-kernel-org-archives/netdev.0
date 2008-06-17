From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/5] sky2: use DEFINE_PCI_DEVICE_TABLE
Date: Tue, 17 Jun 2008 09:04:26 -0700
Message-ID: <20080617160503.524900224@vyatta.com>
References: <20080617160423.205070938@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:50960 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700AbYFQQHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 12:07:44 -0400
Content-Disposition: inline; filename=sky2-pci-table.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI device table can be marked as devinitconst by using macro.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2008-06-16 09:38:35.000000000 -0700
+++ b/drivers/net/sky2.c	2008-06-16 09:38:35.000000000 -0700
@@ -98,7 +98,7 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static const struct pci_device_id sky2_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(sky2_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */

-- 

