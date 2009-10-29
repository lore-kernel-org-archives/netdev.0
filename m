From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/6] sky2: add SK-9E21M device id
Date: Thu, 29 Oct 2009 09:37:05 -0700
Message-ID: <20091029163849.218460323@vyatta.com>
References: <20091029163704.793246334@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57318 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498AbZJ2QjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 12:39:23 -0400
Content-Disposition: inline; filename=sky2-sk-9e21m.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a new ID that just showed up in latest vendor driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-10-28 11:01:10.454251343 -0700
+++ b/drivers/net/sky2.c	2009-10-28 11:01:44.867001737 -0700
@@ -102,6 +102,7 @@ MODULE_PARM_DESC(disable_msi, "Disable M
 static DEFINE_PCI_DEVICE_TABLE(sky2_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
+	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E01) }, /* SK-9E21M */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) }, 	/* DGE-550SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B02) },	/* DGE-560SX */

-- 

