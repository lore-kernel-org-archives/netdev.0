From: Nick Andrew <nick@nick-andrew.net>
Subject: [PATCH] Fix incorrect use of loose in spider_net.c
Date: Fri, 05 Dec 2008 14:08:03 +1100
Message-ID: <20081205030803.32099.345.stgit@marcab.local.tull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, Nick Andrew <nick@nick-andrew.net>
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	Jens Osterkamp <jens@de.ibm.com>,
	Kou Ishizaki <kou.ishizaki@toshiba.co.
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps1.tull.net ([66.180.172.116]:47110 "HELO vps1.tull.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752740AbYLEKU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 05:20:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix incorrect use of loose in spider_net.c

It should be 'lose', not 'loose'.

Signed-off-by: Nick Andrew <nick@nick-andrew.net>
---

 drivers/net/spider_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 07599b4..325fbc9 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -789,7 +789,7 @@ spider_net_set_low_watermark(struct spider_net_card *card)
  * spider_net_release_tx_chain releases the tx descriptors that spider has
  * finished with (if non-brutal) or simply release tx descriptors (if brutal).
  * If some other context is calling this function, we return 1 so that we're
- * scheduled again (if we were scheduled) and will not loose initiative.
+ * scheduled again (if we were scheduled) and will not lose initiative.
  */
 static int
 spider_net_release_tx_chain(struct spider_net_card *card, int brutal)


