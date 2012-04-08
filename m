From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/14] usb/net: rndis: delete duplicate packet types
Date: Sun,  8 Apr 2012 10:48:26 +0200
Message-ID: <1333874906-5104-1-git-send-email-linus.walleij@linaro.org>
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

The NDIS_*-prefixed packet types have equivalent RNDIS_*-
prefixed types, besides nothing in the kernel use these defines.

Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 include/linux/rndis.h |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 705dccc..90ec269 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -173,19 +173,6 @@
 #define NDIS_MINIPORT_SUPPORTS_CANCEL_SEND_PACKETS    0x00800000
 #define NDIS_MINIPORT_64BITS_DMA                      0x01000000
 
-#define NDIS_PACKET_TYPE_DIRECTED	0x00000001
-#define NDIS_PACKET_TYPE_MULTICAST	0x00000002
-#define NDIS_PACKET_TYPE_ALL_MULTICAST	0x00000004
-#define NDIS_PACKET_TYPE_BROADCAST	0x00000008
-#define NDIS_PACKET_TYPE_SOURCE_ROUTING	0x00000010
-#define NDIS_PACKET_TYPE_PROMISCUOUS	0x00000020
-#define NDIS_PACKET_TYPE_SMT		0x00000040
-#define NDIS_PACKET_TYPE_ALL_LOCAL	0x00000080
-#define NDIS_PACKET_TYPE_GROUP		0x00000100
-#define NDIS_PACKET_TYPE_ALL_FUNCTIONAL	0x00000200
-#define NDIS_PACKET_TYPE_FUNCTIONAL	0x00000400
-#define NDIS_PACKET_TYPE_MAC_FRAME	0x00000800
