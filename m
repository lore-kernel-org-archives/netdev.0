From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 03/10] tg3: Add 5717 serdes phy ID
Date: Wed, 20 Jan 2010 18:58:04 -0800
Message-ID: <1264042691-28284-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4732 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509Ab0AUC6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The serdes and copper phys of the 5717 asic rev have different phy IDs.
This patch adds the serdes phy ID.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    3 ++-
 drivers/net/tg3.h |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index adb579f..4a65347 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -14170,7 +14170,8 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case PHY_ID_BCM5756:	return "5722/5756";
 	case PHY_ID_BCM5906:	return "5906";
 	case PHY_ID_BCM5761:	return "5761";
-	case PHY_ID_BCM5717:	return "5717";
+	case PHY_ID_BCM5718C:	return "5718C";
+	case PHY_ID_BCM5718S:	return "5718S";
 	case PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 91139fd..edb7a14 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2893,7 +2893,8 @@ struct tg3 {
 #define PHY_ID_BCM5756			0xbc050ed0
 #define PHY_ID_BCM5784			0xbc050fa0
 #define PHY_ID_BCM5761			0xbc050fd0
-#define PHY_ID_BCM5717			0x5c0d8a00
+#define PHY_ID_BCM5718C			0x5c0d8a00
+#define PHY_ID_BCM5718S			0xbc050ff0
 #define PHY_ID_BCM5906			0xdc00ac40
 #define PHY_ID_BCM8002			0x60010140
 #define PHY_ID_INVALID			0xffffffff
@@ -2936,7 +2937,8 @@ struct tg3 {
 	 (X) == PHY_ID_BCM5780 || (X) == PHY_ID_BCM5787 || \
 	 (X) == PHY_ID_BCM5755 || (X) == PHY_ID_BCM5756 || \
 	 (X) == PHY_ID_BCM5906 || (X) == PHY_ID_BCM5761 || \
-	 (X) == PHY_ID_BCM5717 || (X) == PHY_ID_BCM8002)
+	 (X) == PHY_ID_BCM5718C || (X) == PHY_ID_BCM5718S || \
+	 (X) == PHY_ID_BCM8002)
 
 	struct tg3_hw_stats		*hw_stats;
 	dma_addr_t			stats_mapping;
-- 
1.6.4.4


