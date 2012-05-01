From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/13 v4] usb/net: rndis: move and namespace PnP defines
Date: Tue,  1 May 2012 20:23:30 +0200
Message-ID: <1335896610-13593-1-git-send-email-linus.walleij@linaro.org>
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

This moves the PnP OID definitions to the RNDIS_* namespace
and puts them in the next falling slot in the list. Oh, the comment
above the PnP defines was referring to some obsolete or out-of-tree
driver so removed it, and removed my own comments telling where each
header segment came from as well, we have moved everything around by
this point anyway.

Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 include/linux/rndis.h |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 83b3d70..bdad7ab 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -1,4 +1,7 @@
-/* From include/linux/usb/rndis_host.h */
+/*
+ * Remote Network Driver Interface Specification (RNDIS)
+ * definitions of the magic numbers used by this protocol
+ */
 
 #define RNDIS_MSG_COMPLETION	0x80000000
 
@@ -148,8 +151,6 @@
 #define RNDIS_PACKET_TYPE_FUNCTIONAL		0x00004000
 #define RNDIS_PACKET_TYPE_MAC_FRAME		0x00008000
 
-/* From drivers/usb/gadget/ndis.h */
-
 /* NDIS_PNP_CAPABILITIES.Flags constants */
 #define NDIS_DEVICE_WAKE_UP_ENABLE                0x00000001
 #define NDIS_DEVICE_WAKE_ON_PATTERN_MATCH_ENABLE  0x00000002
@@ -194,8 +195,6 @@
 #define NDIS_MAC_OPTION_8021P_PRIORITY          0x00000040
 #define NDIS_MAC_OPTION_RESERVED                0x80000000
 
-/* From drivers/usb/gadget/rndis.h */
-
 /* Remote NDIS Versions */
 #define RNDIS_MAJOR_VERSION		0x00000001
 #define RNDIS_MINOR_VERSION		0x00000000
@@ -222,16 +221,6 @@
 #define RNDIS_DF_CONNECTION_ORIENTED	0x00000002U
 #define RNDIS_DF_RAW_DATA		0x00000004U
 
-/* from drivers/net/sk98lin/h/skgepnmi.h */
-#define OID_PNP_CAPABILITIES			0xFD010100
-#define OID_PNP_SET_POWER			0xFD010101
-#define OID_PNP_QUERY_POWER			0xFD010102
-#define OID_PNP_ADD_WAKE_UP_PATTERN		0xFD010103
-#define OID_PNP_REMOVE_WAKE_UP_PATTERN		0xFD010104
-#define OID_PNP_ENABLE_WAKE_UP			0xFD010106
-
-/* From drivers/net/hyperv/hyperv_net.h */
