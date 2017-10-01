From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 2/5] net: dsa: b53: Define MAC trunking/bonding registers
Date: Sun,  1 Oct 2017 12:46:36 -0700
Message-ID: <20171001194639.8647-3-f.fainelli@gmail.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us, idosch@mellanox.com, Woojung.Huh@microchip.com,
        john@phrozen.org, sean.wang@mediatek.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36385 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751831AbdJATqv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 15:46:51 -0400
Received: by mail-oi0-f65.google.com with SMTP id a74so2115975oib.3
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 12:46:51 -0700 (PDT)
In-Reply-To: <20171001194639.8647-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define the MAC trunking page offset and its register layout to implement
bonding in the next patches.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_regs.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index 2a9f421680aa..d02e4f7dda10 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -44,6 +44,9 @@
 /* Port VLAN Page */
 #define B53_PVLAN_PAGE			0x31
 
+/* Trunking Page */
+#define B53_TRUNK_PAGE			0x32
+
 /* VLAN Registers */
 #define B53_VLAN_PAGE			0x34
 
@@ -360,6 +363,21 @@
 #define B53_JOIN_ALL_VLAN_EN		0x50
 
 /*************************************************************************
+ * Trunking Registers
+ *************************************************************************/
+
+/* MAC Trunking Control Register (8 bit) */
+#define B53_MAC_TRUNK_CTRL		0x00
+#define  TRK_HASH_IDX_DA_SA		0
+#define  TRK_HASH_IDX_DA		1
+#define  TRK_HASH_IDX_SA		2
+#define  TRK_HASH_IDX_MASK		0x3
+#define  MAC_BASE_TRNK_EN		BIT(3)
+
+/* MAC Trunking Group Register (16 bit) */
+#define B53_MAC_TRUNK_GROUP(x)		(0x10 + (x) * 2)
+
+/*************************************************************************
  * 802.1Q Page Registers
  *************************************************************************/
 
-- 
2.11.0
