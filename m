From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH v2] ray_cs: Add include guards
Date: Mon, 25 Aug 2014 09:59:29 +0200
Message-ID: <1408953569-5647-1-git-send-email-linux@rasmusvillemoes.dk>
References: <87ppfq85bh.fsf@purkki.adurom.net>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: "John W. Linville" <linville@tuxdriver.com>,
	Kalle Valo <kvalo@adurom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ppfq85bh.fsf@purkki.adurom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The files ray_cs.h and rayctl.h both contain two thirds of what
appears to be an include guard using the macro name RAYLINK_H (both
lack the #define). Since RAYLINK_H is not defined anywhere, the
#ifndefs are confusing no-ops. Add proper include guards using
different macro names.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---

Notes:
    v2: Change subject prefix and fix broken commit message.

 drivers/net/wireless/ray_cs.h | 5 +++--
 drivers/net/wireless/rayctl.h | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.h b/drivers/net/wireless/ray_cs.h
index e79848f..524c2f0 100644
--- a/drivers/net/wireless/ray_cs.h
+++ b/drivers/net/wireless/ray_cs.h
@@ -3,7 +3,8 @@
    Written by Corey Thomas
 */
 
-#ifndef RAYLINK_H
+#ifndef _RAY_CS_H_
+#define _RAY_CS_H_
 
 struct beacon_rx {
     struct mac_header mac;
@@ -69,4 +70,4 @@ typedef struct ray_dev_t {
 } ray_dev_t;
 /*****************************************************************************/
 
-#endif /* RAYLINK_H */
+#endif /* _RAY_CS_H_ */
diff --git a/drivers/net/wireless/rayctl.h b/drivers/net/wireless/rayctl.h
index 3c3b98b..b21ed64 100644
--- a/drivers/net/wireless/rayctl.h
+++ b/drivers/net/wireless/rayctl.h
@@ -1,4 +1,5 @@
-#ifndef RAYLINK_H
+#ifndef _RAYCTL_H_
+#define _RAYCTL_H_
 
 typedef unsigned char UCHAR;
 
@@ -729,4 +730,4 @@ typedef struct snaphdr_t
 #define RAY_IPX_TYPE  0x8137
 #define APPLEARP_TYPE 0x80f3
 /*****************************************************************************/
-#endif /* #ifndef RAYLINK_H */
+#endif /* _RAYCTL_H_ */
-- 
2.0.4
