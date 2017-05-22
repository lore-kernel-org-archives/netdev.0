From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 02/11] qed: Align DP_ERR style with other DP macros
Date: Mon, 22 May 2017 14:32:02 +0300
Message-ID: <1495452731-27171-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0062.outbound.protection.outlook.com ([104.47.42.62]:55795
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757646AbdEVLcl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 07:32:41 -0400
In-Reply-To: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
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
