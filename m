From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] bnx2: Increase max rx ring size from 1K to 2K
Date: Mon, 18 Oct 2010 17:30:54 -0700
Message-ID: <1287448254-14173-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, jfeeney@redhat.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4998 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754621Ab0JSB1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 21:27:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of customers are reporting packet loss under certain workloads
(e.g. heavy bursts of small packets) with flow control disabled.  A larger
rx ring helps to prevent these losses.

No change in default rx ring size and memory consumption.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Acked-by: John Feeney <jfeeney@redhat.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index efdfbc2..62ac83e 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6502,8 +6502,8 @@ struct l2_fhdr {
 #define TX_DESC_CNT  (BCM_PAGE_SIZE / sizeof(struct tx_bd))
 #define MAX_TX_DESC_CNT (TX_DESC_CNT - 1)
 
-#define MAX_RX_RINGS	4
-#define MAX_RX_PG_RINGS	16
+#define MAX_RX_RINGS	8
+#define MAX_RX_PG_RINGS	32
 #define RX_DESC_CNT  (BCM_PAGE_SIZE / sizeof(struct rx_bd))
 #define MAX_RX_DESC_CNT (RX_DESC_CNT - 1)
 #define MAX_TOTAL_RX_DESC_CNT (MAX_RX_DESC_CNT * MAX_RX_RINGS)
-- 
1.6.4.GIT


