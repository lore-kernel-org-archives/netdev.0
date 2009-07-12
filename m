From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] atl1c: misplaced parenthesis
Date: Mon, 13 Jul 2009 00:57:38 +0200
Message-ID: <4A5A6A62.6070707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: jcliburn@gmail.com, atl1-devel@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-1920.google.com ([74.125.78.150]:52530 "EHLO
	ey-out-1920.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbZGLW4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 18:56:12 -0400
Received: by ey-out-1920.google.com with SMTP id 3so371069eyh.36
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2009 15:56:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix misplaced parenthesis

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index cd547a2..a383122 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -1689,7 +1689,7 @@ static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter, u8 que,
 		if (likely(RRS_RXD_IS_VALID(rrs->word3))) {
 			rfd_num = (rrs->word0 >> RRS_RX_RFD_CNT_SHIFT) &
 				RRS_RX_RFD_CNT_MASK;
-			if (unlikely(rfd_num) != 1)
+			if (unlikely(rfd_num != 1))
 				/* TODO support mul rfd*/
 				if (netif_msg_rx_err(adapter))
 					dev_warn(&pdev->dev,
