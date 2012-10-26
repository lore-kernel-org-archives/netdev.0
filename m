From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH] dlink: dl2k: use the module_pci_driver macro
Date: Fri, 26 Oct 2012 15:29:00 -0400
Message-ID: <1351279740-16519-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:51707 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966098Ab2JZT3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 15:29:10 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so2977244pbb.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 12:29:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use the module_pci_driver macro to make the code simpler
by eliminating module_init and module_exit calls.

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 drivers/net/ethernet/dlink/dl2k.c |   16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index a059f0c..2fb01bf 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -1758,21 +1758,7 @@ static struct pci_driver rio_driver = {
 	.remove		= __devexit_p(rio_remove1),
 };
 
-static int __init
-rio_init (void)
-{
-	return pci_register_driver(&rio_driver);
-}
-
-static void __exit
-rio_exit (void)
-{
-	pci_unregister_driver (&rio_driver);
-}
-
-module_init (rio_init);
-module_exit (rio_exit);
-
+module_pci_driver(rio_driver);
 /*
 
 Compile command:
-- 
1.7.9.5
