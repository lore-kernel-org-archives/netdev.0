From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH v2] aquantia: Fix driver name reported by ethtool
Date: Wed,  3 May 2017 21:17:44 +0300
Message-ID: <2082aed4d8196250542cf9a73f3d9a49eb96af21.1493835234.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0085.outbound.protection.outlook.com ([104.47.38.85]:30659
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750737AbdECSSR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 14:18:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

V2: using "aquantia" subsystem tag.

The command "ethtool -i ethX" should display driver name (driver: atlantic)
instead vendor name (driver: aquantia).

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h b/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
index 5f99237..2149864 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
@@ -68,7 +68,7 @@
 
 #define AQ_CFG_DRV_AUTHOR      "aQuantia"
 #define AQ_CFG_DRV_DESC        "aQuantia Corporation(R) Network Driver"
-#define AQ_CFG_DRV_NAME        "aquantia"
+#define AQ_CFG_DRV_NAME        "atlantic"
 #define AQ_CFG_DRV_VERSION	__stringify(NIC_MAJOR_DRIVER_VERSION)"."\
 				__stringify(NIC_MINOR_DRIVER_VERSION)"."\
 				__stringify(NIC_BUILD_DRIVER_VERSION)"."\
-- 
2.7.4
