From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] qlge: ql_adapter_down() typo
Date: Sun, 21 Dec 2008 16:28:30 +0100
Message-ID: <494E609E.3090808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:49869 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416AbYLUP2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 10:28:32 -0500
Received: by ug-out-1314.google.com with SMTP id 39so668547ugf.37
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2008 07:28:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index b83a9c9..4a66aa5 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3156,7 +3156,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	 * a workqueue only if it's a single interrupt
 	 * environment (MSI/Legacy).
 	 */
-	for (i = 1; i > qdev->rx_ring_count; i++) {
+	for (i = 1; i < qdev->rx_ring_count; i++) {
 		rx_ring = &qdev->rx_ring[i];
 		/* Only the RSS rings use NAPI on multi irq
 		 * environment.  Outbound completion processing

