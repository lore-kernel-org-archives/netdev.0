From: Linus Walleij <linus.walleij@linaro.org>
Subject: [PATCH 07/14] usb/net: rndis: delete surplus defines
Date: Sun,  8 Apr 2012 10:48:05 +0200
Message-ID: <1333874885-4806-1-git-send-email-linus.walleij@linaro.org>
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
Received: from mail.df.lth.se ([194.47.250.12]:14133 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754994Ab2DHIsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Apr 2012 04:48:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These defines are not used in the kernel, and they have duplicate
definitions under the RNDIS_* prefix.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
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
-
 /* NDIS_PNP_CAPABILITIES.Flags constants */
 #define NDIS_DEVICE_WAKE_UP_ENABLE                0x00000001
 #define NDIS_DEVICE_WAKE_ON_PATTERN_MATCH_ENABLE  0x00000002
-- 
1.7.7.6
