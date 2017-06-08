From: <netanel@amazon.com>
Subject: [PATCH net-next 13/13] net: ena: update ena driver to version 1.2.0
Date: Fri, 9 Jun 2017 01:01:25 +0300
Message-ID: <1496959285-8632-14-git-send-email-netanel@amazon.com>
References: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:22420 "EHLO
        smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752108AbdFHWCe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 18:02:34 -0400
In-Reply-To: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index 4518a9d..f309a58 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -44,15 +44,16 @@
 #include "ena_eth_com.h"
 
 #define DRV_MODULE_VER_MAJOR	1
-#define DRV_MODULE_VER_MINOR	1
-#define DRV_MODULE_VER_SUBMINOR 2
+#define DRV_MODULE_VER_MINOR	2
+#define DRV_MODULE_VER_SUBMINOR 0
 
 #define DRV_MODULE_NAME		"ena"
 #ifndef DRV_MODULE_VERSION
 #define DRV_MODULE_VERSION \
 	__stringify(DRV_MODULE_VER_MAJOR) "."	\
 	__stringify(DRV_MODULE_VER_MINOR) "."	\
-	__stringify(DRV_MODULE_VER_SUBMINOR)
+	__stringify(DRV_MODULE_VER_SUBMINOR) \
+	"k"
 #endif
 
 #define DEVICE_NAME	"Elastic Network Adapter (ENA)"
-- 
2.7.4
