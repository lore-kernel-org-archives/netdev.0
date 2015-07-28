From: Robert ABEL <rabel@cit-ec.uni-bielefeld.de>
Subject: [PATCH] net: rfkill-regulator: fix compiler warning
Date: Tue, 28 Jul 2015 15:47:40 +0200
Message-ID: <1438091260-16062-1-git-send-email-rabel@cit-ec.uni-bielefeld.de>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Robert ABEL <rabel@cit-ec.uni-bielefeld.de>
To: johannes@sipsolutions.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pdata char* name => const char* name

Signed-off-by: Robert ABEL <rabel@cit-ec.uni-bielefeld.de>
---
 include/linux/rfkill-regulator.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/rfkill-regulator.h b/include/linux/rfkill-regulator.h
index aca36bc..594d8e7 100644
--- a/include/linux/rfkill-regulator.h
+++ b/include/linux/rfkill-regulator.h
@@ -41,7 +41,7 @@
 #include <linux/rfkill.h>
 
 struct rfkill_regulator_platform_data {
-	char *name;             /* the name for the rfkill switch */
+	const char *name;       /* the name for the rfkill switch */
 	enum rfkill_type type;  /* the type as specified in rfkill.h */
 };
 
-- 
2.5.0
