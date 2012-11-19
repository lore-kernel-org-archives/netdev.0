From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 029/493] ethernet: remove use of __devexit_p in hydra.c
Date: Mon, 19 Nov 2012 13:19:38 -0500
Message-ID: <1353349642-3677-29-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41682 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459Ab2KSSiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:07 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed, remove it.

Also fix the indentation for the initialization of the hydra_driver
struct to make chkpatch happy.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org 
---
 drivers/net/ethernet/8390/hydra.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index 5370c88..dac977f 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -74,10 +74,10 @@ static struct zorro_device_id hydra_zorro_tbl[] __devinitdata = {
 MODULE_DEVICE_TABLE(zorro, hydra_zorro_tbl);
 
 static struct zorro_driver hydra_driver = {
-    .name	= "hydra",
-    .id_table	= hydra_zorro_tbl,
-    .probe	= hydra_init_one,
-    .remove	= __devexit_p(hydra_remove_one),
+	.name	  = "hydra",
+	.id_table = hydra_zorro_tbl,
+	.probe	  = hydra_init_one,
+	.remove   = hydra_remove_one,
 };
 
 static int __devinit hydra_init_one(struct zorro_dev *z,
-- 
1.8.0
