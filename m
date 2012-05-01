From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 13/13 v4] usb/net: rndis: move bus message definition
Date: Tue,  1 May 2012 20:23:50 +0200
Message-ID: <1335896630-13695-1-git-send-email-linus.walleij@linaro.org>
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
Received: from mail.df.lth.se ([194.47.250.12]:60810 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758182Ab2EASXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 14:23:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves the bus message definition to land together with the
other message types. This message is not used in the kernel but
I'm keeping it anyway.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
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
-
-/*
- * Reserved message type for private communication between lower-layer host
- * driver and remote device, if necessary.
- */
-#define REMOTE_NDIS_BUS_MSG			0xff000001
-- 
1.7.7.6
