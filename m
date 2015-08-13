From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH] net/fddi: remove HWM_REVERSE() macro
Date: Thu, 13 Aug 2015 12:01:33 +0800
Message-ID: <1439438493-9926-1-git-send-email-yalin.wang2010@gmail.com>
Cc: yalin wang <yalin.wang2010@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HWM_REVERSE() macro is unused, remove it.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 drivers/net/fddi/skfp/h/hwmtm.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/fddi/skfp/h/hwmtm.h b/drivers/net/fddi/skfp/h/hwmtm.h
index 5924d42..4ca2341 100644
--- a/drivers/net/fddi/skfp/h/hwmtm.h
+++ b/drivers/net/fddi/skfp/h/hwmtm.h
@@ -74,15 +74,6 @@
 #define NULL 		0
 #endif
 
-#ifdef	LITTLE_ENDIAN
-#define HWM_REVERSE(x)	(x)
-#else
-#define	HWM_REVERSE(x)		((((x)<<24L)&0xff000000L)	+	\
-				 (((x)<< 8L)&0x00ff0000L)	+	\
-				 (((x)>> 8L)&0x0000ff00L)	+	\
-				 (((x)>>24L)&0x000000ffL))
-#endif
-
 #define C_INDIC		(1L<<25)
 #define A_INDIC		(1L<<26)
 #define	RD_FS_LOCAL	0x80
-- 
1.9.1
