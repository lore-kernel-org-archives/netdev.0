From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] sungem: another error printed one too early
Date: Mon, 16 Feb 2009 15:02:04 +0100
Message-ID: <499971DC.4070406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Walker <dwalker@fifo99.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:44743 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755087AbZBPOCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 09:02:07 -0500
Received: by fxm13 with SMTP id 13so5842857fxm.13
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2009 06:02:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another error was printed one too early.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4918763..8d64b1d 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1157,7 +1157,7 @@ static void gem_pcs_reset(struct gem *gp)
 		if (limit-- <= 0)
 			break;
 	}
-	if (limit <= 0)
+	if (limit < 0)
 		printk(KERN_WARNING "%s: PCS reset bit would not clear.\n",
 		       gp->dev->name);
 }
