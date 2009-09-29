From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/5] qlge: Fix bad bit definitions.
Date: Tue, 29 Sep 2009 11:39:21 -0700
Message-ID: <1254249565-16381-2-git-send-email-ron.mercer@qlogic.com>
References: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:8737 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbZI2SpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 14:45:15 -0400
In-Reply-To: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index a9845a2..30d5585 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1381,15 +1381,15 @@ struct intr_context {
 
 /* adapter flags definitions. */
 enum {
-	QL_ADAPTER_UP = (1 << 0),	/* Adapter has been brought up. */
-	QL_LEGACY_ENABLED = (1 << 3),
-	QL_MSI_ENABLED = (1 << 3),
-	QL_MSIX_ENABLED = (1 << 4),
-	QL_DMA64 = (1 << 5),
-	QL_PROMISCUOUS = (1 << 6),
-	QL_ALLMULTI = (1 << 7),
-	QL_PORT_CFG = (1 << 8),
-	QL_CAM_RT_SET = (1 << 9),
+	QL_ADAPTER_UP = 0,	/* Adapter has been brought up. */
+	QL_LEGACY_ENABLED = 1,
+	QL_MSI_ENABLED = 2,
+	QL_MSIX_ENABLED = 3,
+	QL_DMA64 = 4,
+	QL_PROMISCUOUS = 5,
+	QL_ALLMULTI = 6,
+	QL_PORT_CFG = 7,
+	QL_CAM_RT_SET = 8,
 };
 
 /* link_status bit definitions */
-- 
1.6.0.2

