From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: ethernet: slicoss: use module_pci_driver()
Date: Wed,  7 Dec 2016 14:43:30 +0100
Message-ID: <20161207134330.8829-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34386 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752918AbcLGNnd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 08:43:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use module_pci_driver() to get rid of some boilerplate code.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/alacritech/slicoss.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/alacritech/slicoss.c b/drivers/net/ethernet/alacritech/slicoss.c
index e77ecd5b307c..b9fbd0107008 100644
--- a/drivers/net/ethernet/alacritech/slicoss.c
+++ b/drivers/net/ethernet/alacritech/slicoss.c
@@ -1863,18 +1863,7 @@ static struct pci_driver slic_driver = {
 	.remove = slic_remove,
 };
 
-static int __init slic_init_module(void)
-{
-	return pci_register_driver(&slic_driver);
-}
-
-static void __exit slic_cleanup_module(void)
-{
-	pci_unregister_driver(&slic_driver);
-}
-
-module_init(slic_init_module);
-module_exit(slic_cleanup_module);
+module_pci_driver(slic_driver);
 
 MODULE_DESCRIPTION("Alacritech non-accelerated SLIC driver");
 MODULE_AUTHOR("Lino Sanfilippo <LinoSanfilippo@gmx.de>");
-- 
2.11.0
