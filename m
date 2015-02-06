From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 7/7] r8152: use BIT macro
Date: Fri, 6 Feb 2015 11:30:51 +0800
Message-ID: <1394712342-15778-136-Taiwan-albertk@realtek.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
 <1394712342-15778-129-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60459 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754517AbbBFDbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 22:31:52 -0500
In-Reply-To: <1394712342-15778-129-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use BIT macro to replace (1 << bits).

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 24e6aef9..5980ac6 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -489,16 +489,16 @@ struct rx_desc {
 #define RX_LEN_MASK			0x7fff
 
 	__le32 opts2;
-#define RD_UDP_CS			(1 << 23)
-#define RD_TCP_CS			(1 << 22)
-#define RD_IPV6_CS			(1 << 20)
-#define RD_IPV4_CS			(1 << 19)
+#define RD_UDP_CS			BIT(23)
+#define RD_TCP_CS			BIT(22)
+#define RD_IPV6_CS			BIT(20)
+#define RD_IPV4_CS			BIT(19)
 
 	__le32 opts3;
-#define IPF				(1 << 23) /* IP checksum fail */
-#define UDPF				(1 << 22) /* UDP checksum fail */
-#define TCPF				(1 << 21) /* TCP checksum fail */
-#define RX_VLAN_TAG			(1 << 16)
+#define IPF				BIT(23) /* IP checksum fail */
+#define UDPF				BIT(22) /* UDP checksum fail */
+#define TCPF				BIT(21) /* TCP checksum fail */
+#define RX_VLAN_TAG			BIT(16)
 
 	__le32 opts4;
 	__le32 opts5;
@@ -507,24 +507,24 @@ struct rx_desc {
 
 struct tx_desc {
 	__le32 opts1;
-#define TX_FS			(1 << 31) /* First segment of a packet */
-#define TX_LS			(1 << 30) /* Final segment of a packet */
-#define GTSENDV4		(1 << 28)
-#define GTSENDV6		(1 << 27)
+#define TX_FS			BIT(31) /* First segment of a packet */
+#define TX_LS			BIT(30) /* Final segment of a packet */
+#define GTSENDV4		BIT(28)
+#define GTSENDV6		BIT(27)
 #define GTTCPHO_SHIFT		18
 #define GTTCPHO_MAX		0x7fU
 #define TX_LEN_MAX		0x3ffffU
 
 	__le32 opts2;
-#define UDP_CS			(1 << 31) /* Calculate UDP/IP checksum */
-#define TCP_CS			(1 << 30) /* Calculate TCP/IP checksum */
-#define IPV4_CS			(1 << 29) /* Calculate IPv4 checksum */
-#define IPV6_CS			(1 << 28) /* Calculate IPv6 checksum */
+#define UDP_CS			BIT(31) /* Calculate UDP/IP checksum */
+#define TCP_CS			BIT(30) /* Calculate TCP/IP checksum */
+#define IPV4_CS			BIT(29) /* Calculate IPv4 checksum */
+#define IPV6_CS			BIT(28) /* Calculate IPv6 checksum */
 #define MSS_SHIFT		17
 #define MSS_MAX			0x7ffU
 #define TCPHO_SHIFT		17
 #define TCPHO_MAX		0x7ffU
-#define TX_VLAN_TAG			(1 << 16)
+#define TX_VLAN_TAG		BIT(16)
 };
 
 struct r8152;
-- 
2.1.0
