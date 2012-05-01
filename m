From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/13 v4] usb/net: rndis: delete surplus defines
Date: Tue,  1 May 2012 20:23:03 +0200
Message-ID: <1335896583-13452-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These defines are not used in the kernel, and they have duplicate
definitions under the RNDIS_* prefix.

Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 include/linux/rndis.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 62aecb7..70bd80a 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -58,10 +58,6 @@
 
 /* From drivers/usb/gadget/ndis.h */
 
-#define NDIS_STATUS_MULTICAST_FULL	  0xC0010009
-#define NDIS_STATUS_MULTICAST_EXISTS      0xC001000A
-#define NDIS_STATUS_MULTICAST_NOT_FOUND   0xC001000B
