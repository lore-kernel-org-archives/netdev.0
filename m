From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] atm: add missing parentheses
Date: Tue, 17 Feb 2009 14:29:30 +0100
Message-ID: <499ABBBA.6000404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:40739 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbZBQN3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 08:29:32 -0500
Received: by bwz5 with SMTP id 5so4038480bwz.13
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 05:29:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing parentheses

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 98099f5..60c4513 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1693,14 +1693,14 @@ static int __devinit fs_init (struct fs_dev *dev)
 		  | IS_FS50(dev)?SARMODE0_PRPWT_FS50_5: 
 		                 SARMODE0_PRPWT_FS155_3
 		  | (1 * SARMODE0_CALSUP_1)
-		  | IS_FS50 (dev)?(0
+		  | (IS_FS50(dev) ? (0
 				   | SARMODE0_RXVCS_32
 				   | SARMODE0_ABRVCS_32 
 				   | SARMODE0_TXVCS_32):
 		                  (0
 				   | SARMODE0_RXVCS_1k
 				   | SARMODE0_ABRVCS_1k 
-				   | SARMODE0_TXVCS_1k));
+				   | SARMODE0_TXVCS_1k)));
 
 	/* 10ms * 100 is 1 second. That should be enough, as AN3:9 says it takes
 	   1ms. */
