From: <netanel@amazon.com>
Subject: [PATCH net-next 13/13] net: ena: update ena driver to version 1.2.0
Date: Sun, 18 Jun 2017 14:28:18 +0300
Message-ID: <1497785298-13468-14-git-send-email-netanel@amazon.com>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:9358 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752812AbdFRLaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 07:30:52 -0400
In-Reply-To: <1497785298-13468-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index 86b0f0dbae65..29bb5704260b 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -44,15 +44,15 @@
 #include "ena_eth_com.h"
 
 #define DRV_MODULE_VER_MAJOR	1
-#define DRV_MODULE_VER_MINOR	1
-#define DRV_MODULE_VER_SUBMINOR 7
+#define DRV_MODULE_VER_MINOR	2
+#define DRV_MODULE_VER_SUBMINOR 0
 
 #define DRV_MODULE_NAME		"ena"
 #ifndef DRV_MODULE_VERSION
 #define DRV_MODULE_VERSION \
 	__stringify(DRV_MODULE_VER_MAJOR) "."	\
 	__stringify(DRV_MODULE_VER_MINOR) "."	\
-	__stringify(DRV_MODULE_VER_SUBMINOR)
+	__stringify(DRV_MODULE_VER_SUBMINOR) "k"
 #endif
 
 #define DEVICE_NAME	"Elastic Network Adapter (ENA)"
-- 
2.7.4
