From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 01/20] tg3: Add 5717 phy ID
Date: Fri, 13 Nov 2009 15:03:33 -0800
Message-ID: <1258153432-7036-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3244 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932407AbZKMXER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 5717 phy ID.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    1 +
 drivers/net/tg3.h |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 47a4f09..fc9df25 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13755,6 +13755,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case PHY_ID_BCM5756:	return "5722/5756";
 	case PHY_ID_BCM5906:	return "5906";
 	case PHY_ID_BCM5761:	return "5761";
+	case PHY_ID_BCM5717:	return "5717";
 	case PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d770da1..e0a8b61 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2855,6 +2855,7 @@ struct tg3 {
 #define PHY_ID_BCM5756			0xbc050ed0
 #define PHY_ID_BCM5784			0xbc050fa0
 #define PHY_ID_BCM5761			0xbc050fd0
+#define PHY_ID_BCM5717			0x5c0d8a00
 #define PHY_ID_BCM5906			0xdc00ac40
 #define PHY_ID_BCM8002			0x60010140
 #define PHY_ID_INVALID			0xffffffff
@@ -2896,7 +2897,7 @@ struct tg3 {
 	 (X) == PHY_ID_BCM5780 || (X) == PHY_ID_BCM5787 || \
 	 (X) == PHY_ID_BCM5755 || (X) == PHY_ID_BCM5756 || \
 	 (X) == PHY_ID_BCM5906 || (X) == PHY_ID_BCM5761 || \
-	 (X) == PHY_ID_BCM8002)
+	 (X) == PHY_ID_BCM5717 || (X) == PHY_ID_BCM8002)
 
 	struct tg3_hw_stats		*hw_stats;
 	dma_addr_t			stats_mapping;
-- 
1.6.4.4


