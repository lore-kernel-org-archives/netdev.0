From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/14 v2] usb/net: rndis: move bus message definition
Date: Wed, 25 Apr 2012 17:36:16 +0200
Message-ID: <1335368176-4862-1-git-send-email-linus.walleij@linaro.org>
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

This moves the bus message definition to land together with the
other message types. This message is not used in the kernel but
I'm keeping it anyway.

Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 include/linux/rndis.h |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 3f2ba8f..0c8dc71 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -31,6 +31,11 @@
 #define RNDIS_MSG_INDICATE	0x00000007
 #define RNDIS_MSG_KEEPALIVE	0x00000008
 #define RNDIS_MSG_KEEPALIVE_C	(RNDIS_MSG_KEEPALIVE|RNDIS_MSG_COMPLETION)
+/*
+ * Reserved message type for private communication between lower-layer host
+ * driver and remote device, if necessary.
+ */
+#define RNDIS_MSG_BUS		0xff000001
 
 /* codes for "status" field of completion messages */
 #define	RNDIS_STATUS_SUCCESS			0x00000000
@@ -383,9 +388,3 @@
 #define REMOTE_CONDIS_MP_DELETE_VC_CMPLT	0x80008002
 #define REMOTE_CONDIS_MP_ACTIVATE_VC_CMPLT	0x80008005
 #define REMOTE_CONDIS_MP_DEACTIVATE_VC_CMPLT	0x80008006
