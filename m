From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH] realtek: r8169: use module_pci_driver macro
Date: Fri, 26 Oct 2012 15:27:42 -0400
Message-ID: <1351279662-16466-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:46290 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966144Ab2JZT1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 15:27:50 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so2134374pad.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 12:27:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use the module_pci_driver macro to make the code simpler
by eliminating the module_init and module_exit calls

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c |   13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2317b8c..123c6a5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7023,15 +7023,4 @@ static struct pci_driver rtl8169_pci_driver = {
 	.driver.pm	= RTL8169_PM_OPS,
 };
 
-static int __init rtl8169_init_module(void)
-{
-	return pci_register_driver(&rtl8169_pci_driver);
-}
-
-static void __exit rtl8169_cleanup_module(void)
-{
-	pci_unregister_driver(&rtl8169_pci_driver);
-}
-
-module_init(rtl8169_init_module);
-module_exit(rtl8169_cleanup_module);
+module_pci_driver(rtl8169_pci_driver);
-- 
1.7.9.5
