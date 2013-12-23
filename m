From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 3/3] cxgb4: Changed FW check version to match FW binary version
Date: Mon, 23 Dec 2013 17:02:00 +0530
Message-ID: <1387798320-29255-4-git-send-email-hariprasad@chelsio.com>
References: <1387798320-29255-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24415 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757205Ab3LWLjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 06:39:52 -0500
In-Reply-To: <1387798320-29255-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 0d5b365..ddf7f8b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -50,13 +50,13 @@
 #include "cxgb4_uld.h"
 
 #define T4FW_VERSION_MAJOR 0x01
-#define T4FW_VERSION_MINOR 0x06
-#define T4FW_VERSION_MICRO 0x18
+#define T4FW_VERSION_MINOR 0x09
+#define T4FW_VERSION_MICRO 0x17
 #define T4FW_VERSION_BUILD 0x00
 
 #define T5FW_VERSION_MAJOR 0x01
-#define T5FW_VERSION_MINOR 0x08
-#define T5FW_VERSION_MICRO 0x1C
+#define T5FW_VERSION_MINOR 0x09
+#define T5FW_VERSION_MICRO 0x17
 #define T5FW_VERSION_BUILD 0x00
 
 #define CH_WARN(adap, fmt, ...) dev_warn(adap->pdev_dev, fmt, ## __VA_ARGS__)
-- 
1.8.0
