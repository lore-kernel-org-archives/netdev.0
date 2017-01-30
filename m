From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 2/4] net: dsa: b53: Add mirror capture register definitions
Date: Sun, 29 Jan 2017 20:30:24 -0800
Message-ID: <20170130043026.28867-3-f.fainelli@gmail.com>
References: <20170130043026.28867-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        jiri@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36268 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751910AbdA3Eaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 23:30:39 -0500
Received: by mail-qk0-f195.google.com with SMTP id i34so14595520qkh.3
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 20:30:38 -0800 (PST)
In-Reply-To: <20170130043026.28867-1-f.fainelli@gmail.com>
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
