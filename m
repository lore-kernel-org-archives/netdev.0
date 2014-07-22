From: varkabhadram@gmail.com
Subject: [PATCH net-next 1/2] ethernet: realtek: use module_pci_driver
Date: Tue, 22 Jul 2014 11:28:47 +0530
Message-ID: <1406008728-22604-2-git-send-email-varkabhadram@gmail.com>
References: <1406008728-22604-1-git-send-email-varkabhadram@gmail.com>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:49283 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbaGVGAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 02:00:24 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so10804225pab.14
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 23:00:23 -0700 (PDT)
In-Reply-To: <1406008728-22604-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch converts to use the macro module_pci_driver, which makes
the code smaller and simpler.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/realtek/8139cp.c |   16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 2bc728e..9025fba 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -2121,18 +2121,4 @@ static struct pci_driver cp_driver = {
 #endif
 };
 
-static int __init cp_init (void)
-{
-#ifdef MODULE
-	pr_info("%s", version);
-#endif
-	return pci_register_driver(&cp_driver);
-}
-
-static void __exit cp_exit (void)
-{
-	pci_unregister_driver (&cp_driver);
-}
-
-module_init(cp_init);
-module_exit(cp_exit);
+module_pci_driver(cp_driver);
-- 
1.7.9.5
