From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 026/493] atm: remove use of __devexit_p in fore200e.c
Date: Mon, 19 Nov 2012 13:19:35 -0500
Message-ID: <1353349642-3677-26-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41654 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754517Ab2KSSiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:07 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed, remove it.

Also fix the indentation for the initialization of the
fore200e_pca_driver struct to make chkpatch happy.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil> 
Cc: linux-atm-general@lists.sourceforge.net 
Cc: netdev@vger.kernel.org 
---
 drivers/atm/fore200e.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 361f5ae..c162162 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2707,7 +2707,7 @@ static struct platform_driver fore200e_sba_driver = {
 		.of_match_table = fore200e_sba_match,
 	},
 	.probe		= fore200e_sba_probe,
-	.remove		= __devexit_p(fore200e_sba_remove),
+	.remove		= fore200e_sba_remove,
 };
 #endif
 
@@ -2787,10 +2787,10 @@ static struct pci_device_id fore200e_pca_tbl[] = {
 MODULE_DEVICE_TABLE(pci, fore200e_pca_tbl);
 
 static struct pci_driver fore200e_pca_driver = {
-    .name =     "fore_200e",
-    .probe =    fore200e_pca_detect,
-    .remove =   __devexit_p(fore200e_pca_remove_one),
-    .id_table = fore200e_pca_tbl,
+	.name =	    "fore_200e",
+	.probe =    fore200e_pca_detect,
+	.remove =   fore200e_pca_remove_one,
+	.id_table = fore200e_pca_tbl,
 };
 #endif
 
-- 
1.8.0
