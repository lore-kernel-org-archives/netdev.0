From: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] codel: cast the output of MS2TIME to codel_time_t
Date: Mon, 22 Feb 2016 13:49:47 +0200
Message-ID: <1456141787-18143-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This will allow to pass the typecheck in the comparators:
codel_time_{after,before}

Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/net/codel.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index 267e702..0d92e39 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -62,7 +62,7 @@
 typedef u32 codel_time_t;
 typedef s32 codel_tdiff_t;
 #define CODEL_SHIFT 10
-#define MS2TIME(a) ((a * NSEC_PER_MSEC) >> CODEL_SHIFT)
+#define MS2TIME(a) ((codel_time_t)((a * NSEC_PER_MSEC) >> CODEL_SHIFT))
 
 static inline codel_time_t codel_get_time(void)
 {
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
