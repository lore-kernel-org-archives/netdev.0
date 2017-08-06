From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] isdn: kcapi: make capi_version const
Date: Sun,  6 Aug 2017 22:39:06 +0530
Message-ID: <1502039346-3675-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, isdn@linux-pingi.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare this structure as const as it is only used during a copy
operation.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/isdn/capi/kcapi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index 9ca691d..46c189a 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -55,7 +55,7 @@ struct capictr_event {
 
 /* ------------------------------------------------------------- */
 
-static struct capi_version driver_version = {2, 0, 1, 1 << 4};
+static const struct capi_version driver_version = {2, 0, 1, 1 << 4};
 static char driver_serial[CAPI_SERIAL_LEN] = "0004711";
 static char capi_manufakturer[64] = "AVM Berlin";
 
-- 
1.9.1
