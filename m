From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 02/11] qed: Align DP_ERR style with other DP macros
Date: Tue, 23 May 2017 09:41:19 +0300
Message-ID: <1495521688-27669-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0089.outbound.protection.outlook.com ([104.47.37.89]:22336
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761848AbdEWGmV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 02:42:21 -0400
In-Reply-To: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 include/linux/qed/qed_if.h | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index c70ac13..ff590cb 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -700,11 +700,13 @@ struct qed_common_ops {
 	(((value) >> (name ## _SHIFT)) & name ## _MASK)
 
 /* Debug print definitions */
-#define DP_ERR(cdev, fmt, ...)						     \
-		pr_err("[%s:%d(%s)]" fmt,				     \
-		       __func__, __LINE__,				     \
-		       DP_NAME(cdev) ? DP_NAME(cdev) : "",		     \
-		       ## __VA_ARGS__)					     \
+#define DP_ERR(cdev, fmt, ...)					\
+	do {							\
+		pr_err("[%s:%d(%s)]" fmt,			\
+		       __func__, __LINE__,			\
+		       DP_NAME(cdev) ? DP_NAME(cdev) : "",	\
+		       ## __VA_ARGS__);				\
+	} while (0)
 
 #define DP_NOTICE(cdev, fmt, ...)				      \
 	do {							      \
-- 
1.9.3
