From: avi.kp.137-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH 6/6] drivers:net:wireless:airo.c:checkpatch.pl cleanup
Date: Tue, 18 Feb 2014 17:04:10 +0530
Message-ID: <5303453d.82e6440a.29fb.6ba4@mx.google.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Avinash kumar <avi.kp.137-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Avinash kumar <avi.kp.137-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

removed following warnings-
drivers/net/wireless/airo.c:39: WARNING: Use #include <linux/io.h> instead of <asm/io.h>
drivers/net/wireless/airo.c:48: WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>

Signed-off-by: Avinash Kumar <avi.kp.137-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/airo.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index edf4b57..79c4a76 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -36,7 +36,7 @@
 #include <linux/bitops.h>
 #include <linux/scatterlist.h>
 #include <linux/crypto.h>
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/unaligned.h>
 
 #include <linux/netdevice.h>
@@ -45,7 +45,7 @@
 #include <linux/if_arp.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
