From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 11/14 v2] usb/net: rndis: move and namespace PnP defines
Date: Wed, 25 Apr 2012 17:35:57 +0200
Message-ID: <1335368157-4757-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:37381 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755332Ab2DYPgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 11:36:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves the PnP OID definitions to the RNDIS_* namespace
and puts them in the next falling slot in the list. Oh, the comment
above the PnP defines was referring to some obsolete or out-of-tree
driver so removed it, and removed my own comments telling where each
header segment came from as well, we have moved everything around by
this point anyway.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
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
-
 /* Object Identifiers used by NdisRequest Query/Set Information */
 /* General (Required) Objects */
 #define RNDIS_OID_GEN_SUPPORTED_LIST		0x00010101
@@ -396,6 +385,14 @@
 #define RNDIS_OID_802_11_POWER_MODE			0x0d010216
 #define RNDIS_OID_802_11_BSSID_LIST			0x0d010217
 
+/* Plug and Play capabilities */
+#define RNDIS_OID_PNP_CAPABILITIES		0xFD010100
+#define RNDIS_OID_PNP_SET_POWER			0xFD010101
+#define RNDIS_OID_PNP_QUERY_POWER		0xFD010102
+#define RNDIS_OID_PNP_ADD_WAKE_UP_PATTERN	0xFD010103
+#define RNDIS_OID_PNP_REMOVE_WAKE_UP_PATTERN	0xFD010104
+#define RNDIS_OID_PNP_ENABLE_WAKE_UP		0xFD010106
+
 #define REMOTE_CONDIS_MP_CREATE_VC_MSG		0x00008001
 #define REMOTE_CONDIS_MP_DELETE_VC_MSG		0x00008002
 #define REMOTE_CONDIS_MP_ACTIVATE_VC_MSG	0x00008005
-- 
1.7.7.6
