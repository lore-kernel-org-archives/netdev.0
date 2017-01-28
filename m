From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: dsa: b53: Add mirror capture register definitions
Date: Fri, 27 Jan 2017 16:40:33 -0800
Message-ID: <20170128004035.26035-3-f.fainelli@gmail.com>
References: <20170128004035.26035-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33088 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751230AbdA1Ato (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 19:49:44 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so26174324pgd.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 16:49:17 -0800 (PST)
In-Reply-To: <20170128004035.26035-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add definitions for the different Roboswitch registers relevant for
ingress and egress mirroring.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_regs.h | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index dac0af4e2cd0..9fd24c418fa4 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -206,6 +206,38 @@
 #define   BRCM_HDR_P8_EN		BIT(0) /* Enable tagging on port 8 */
 #define   BRCM_HDR_P5_EN		BIT(1) /* Enable tagging on port 5 */
 
+/* Mirror capture control register (16 bit) */
+#define B53_MIR_CAP_CTL			0x10
+#define  CAP_PORT_MASK			0xf
+#define  BLK_NOT_MIR			BIT(14)
+#define  MIRROR_EN			BIT(15)
+
+/* Ingress mirror control register (16 bit) */
+#define B53_IG_MIR_CTL			0x12
+#define  MIRROR_MASK			0x1ff
+#define  DIV_EN				BIT(13)
+#define  MIRROR_FILTER_MASK		0x3
+#define  MIRROR_FILTER_SHIFT		14
+#define  MIRROR_ALL			0
+#define  MIRROR_DA			1
+#define  MIRROR_SA			2
+
+/* Ingress mirror divider register (16 bit) */
+#define B53_IG_MIR_DIV			0x14
+#define  IN_MIRROR_DIV_MASK		0x3ff
+
+/* Ingress mirror MAC address register (48 bit) */
+#define B53_IG_MIR_MAC			0x16
+
+/* Egress mirror control register (16 bit) */
+#define B53_EG_MIR_CTL			0x1C
+
+/* Egress mirror divider register (16 bit) */
+#define B53_EG_MIR_DIV			0x1E
+
+/* Egress mirror MAC address register (48 bit) */
+#define B53_EG_MIR_MAC			0x20
+
 /* Device ID register (8 or 32 bit) */
 #define B53_DEVICE_ID			0x30
 
-- 
2.9.3
