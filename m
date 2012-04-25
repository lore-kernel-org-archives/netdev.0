From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 10/14 v2] usb/net: rndis: delete duplicate packet types
Date: Wed, 25 Apr 2012 17:35:50 +0200
Message-ID: <1335368150-4722-1-git-send-email-linus.walleij@linaro.org>
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
Received: from mail.df.lth.se ([194.47.250.12]:37376 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754910Ab2DYPfy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 11:35:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NDIS_*-prefixed packet types have equivalent RNDIS_*-
prefixed types, besides nothing in the kernel use these defines.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 include/linux/rndis.h |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 4857959..83b3d70 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -185,19 +185,6 @@
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
-
 #define NDIS_MAC_OPTION_COPY_LOOKAHEAD_DATA     0x00000001
 #define NDIS_MAC_OPTION_RECEIVE_SERIALIZED      0x00000002
 #define NDIS_MAC_OPTION_TRANSFERS_NOT_PEND      0x00000004
-- 
1.7.7.6
