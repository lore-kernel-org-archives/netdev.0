From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/7] tg3: Add 5720 PHY ID
Date: Mon, 4 Apr 2011 11:24:52 -0700
Message-ID: <1301941495-8069-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1315 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112Ab1DDSTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:19:18 -0400
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
index fa40632..525f5d7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -14690,6 +14690,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case TG3_PHY_ID_BCM5718S:	return "5718S";
 	case TG3_PHY_ID_BCM57765:	return "57765";
 	case TG3_PHY_ID_BCM5719C:	return "5719C";
+	case TG3_PHY_ID_BCM5720C:	return "5720C";
 	case TG3_PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 39375ed..0debdf9 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -3029,6 +3029,7 @@ struct tg3 {
 #define TG3_PHY_ID_BCM5718S		0xbc050ff0
 #define TG3_PHY_ID_BCM57765		0x5c0d8a40
 #define TG3_PHY_ID_BCM5719C		0x5c0d8a20
+#define TG3_PHY_ID_BCM5720C		0x5c0d8b60
 #define TG3_PHY_ID_BCM5906		0xdc00ac40
 #define TG3_PHY_ID_BCM8002		0x60010140
 #define TG3_PHY_ID_INVALID		0xffffffff
-- 
1.7.3.4


