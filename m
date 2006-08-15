From: akpm@osdl.org
Subject: [patch 38/41] xircom_cb: wire up errors from pci_register_driver()
Date: Mon, 14 Aug 2006 23:00:28 -0700
Message-ID: <200608150600.k7F60TuO012760@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, adobriyan@gmail.com,
	linux@dominikbrodowski.net, val_henson@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42392 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965209AbWHOGRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:17:23 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Valerie Henson <val_henson@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tulip/xircom_cb.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/tulip/xircom_cb.c~xircom_cb-wire-up-errors-from-pci_register_driver drivers/net/tulip/xircom_cb.c
--- a/drivers/net/tulip/xircom_cb.c~xircom_cb-wire-up-errors-from-pci_register_driver
+++ a/drivers/net/tulip/xircom_cb.c
@@ -1264,8 +1264,7 @@ static void investigate_write_descriptor
 
 static int __init xircom_init(void)
 {
-	pci_register_driver(&xircom_ops);
-	return 0;
+	return pci_register_driver(&xircom_ops);
 }
 
 static void __exit xircom_exit(void)
_
