From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 net-next 7/9] tg3: Add 5720 PHY ID
Date: Tue, 5 Apr 2011 17:22:49 -0700
Message-ID: <1302049371-13799-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4469 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743Ab1DFAQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 20:16:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 5720 PHY ID.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    1 +
 drivers/net/tg3.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 263f151..886174d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -14673,6 +14673,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case TG3_PHY_ID_BCM5718S:	return "5718S";
 	case TG3_PHY_ID_BCM57765:	return "57765";
 	case TG3_PHY_ID_BCM5719C:	return "5719C";
+	case TG3_PHY_ID_BCM5720C:	return "5720C";
 	case TG3_PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a936727..e7880d5 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -3035,6 +3035,7 @@ struct tg3 {
 #define TG3_PHY_ID_BCM5718S		0xbc050ff0
 #define TG3_PHY_ID_BCM57765		0x5c0d8a40
 #define TG3_PHY_ID_BCM5719C		0x5c0d8a20
+#define TG3_PHY_ID_BCM5720C		0x5c0d8b60
 #define TG3_PHY_ID_BCM5906		0xdc00ac40
 #define TG3_PHY_ID_BCM8002		0x60010140
 #define TG3_PHY_ID_INVALID		0xffffffff
-- 
1.7.3.4


