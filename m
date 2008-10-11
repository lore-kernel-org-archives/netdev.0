From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/6] [NET-NEXT]qlge: Reduce debug print levels.
Date: Sat, 11 Oct 2008 10:17:09 -0700
Message-ID: <1223745433-26440-2-git-send-email-ron.mercer@qlogic.com>
References: <20081011171614.GA26384@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:13301 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760557AbYJKRRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 13:17:16 -0400
In-Reply-To: <20081011171614.GA26384@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 77a66e5..1cce8dc 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -59,7 +59,8 @@ static const u32 default_msg =
     NETIF_MSG_RX_ERR |
     NETIF_MSG_TX_ERR |
     NETIF_MSG_TX_QUEUED |
-    NETIF_MSG_INTR | NETIF_MSG_TX_DONE | NETIF_MSG_RX_STATUS |
+    NETIF_MSG_INTR | NETIF_MSG_TX_DONE | 
+/* NETIF_MSG_RX_STATUS | */
 /* NETIF_MSG_PKTDATA | */
     NETIF_MSG_HW | NETIF_MSG_WOL | 0;
 
-- 
1.6.0

