From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] atm: add missing parentheses
Date: Wed, 18 Feb 2009 13:34:14 +0100
Message-ID: <499C0046.2010000@gmail.com>
References: <499ABBBA.6000404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:47606 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbZBRMeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 07:34:17 -0500
Received: by bwz5 with SMTP id 5so5352658bwz.13
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 04:34:15 -0800 (PST)
In-Reply-To: <499ABBBA.6000404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I previously sent this, but missed the first.
--------------------------->8-------------8<------------------------------
Add missing parentheses

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 98099f5..b119640 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1690,17 +1690,17 @@ static int __devinit fs_init (struct fs_dev *dev)
 		  | (0 * SARMODE0_SHADEN) /* We don't use shadow registers. */
 		  | (1 * SARMODE0_INTMODE_READCLEAR)
 		  | (1 * SARMODE0_CWRE)
-		  | IS_FS50(dev)?SARMODE0_PRPWT_FS50_5: 
-		                 SARMODE0_PRPWT_FS155_3
+		  | (IS_FS50(dev) ? SARMODE0_PRPWT_FS50_5:
+			  SARMODE0_PRPWT_FS155_3)
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

