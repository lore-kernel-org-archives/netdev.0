From: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH Resend 1/2] net/usb: r8152: Remove redundant version.h header inclusion
Date: Fri, 17 May 2013 09:18:07 +0530
Message-ID: <1368762488-22017-1-git-send-email-sachin.kamat@linaro.org>
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

version.h header inclusion is not necessary as detected by
checkversion.pl.

Signed-off-by: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
This series compile tested on linux-next (20130516).
---
 drivers/net/usb/r8152.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 14e5198..8e53e41 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -11,7 +11,6 @@
 #include <linux/signal.h>
 #include <linux/slab.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
