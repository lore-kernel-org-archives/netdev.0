From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next v3 3/3] net: ethernet: mediatek: add the dts property to set if the HW supports LRO
Date: Sat, 17 Sep 2016 23:50:57 +0800
Message-ID: <1474127457-13143-4-git-send-email-nelson.chang@mediatek.com>
References: <1474127457-13143-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:19162 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752389AbcIQPvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 11:51:10 -0400
In-Reply-To: <1474127457-13143-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the dts property for the capability if the hardware supports LRO.

Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
---
 Documentation/devicetree/bindings/net/mediatek-net.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index 32eaaca..6103e55 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -24,7 +24,7 @@ Required properties:
 Optional properties:
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
-
+- mediatek,hwlro: the capability if the hardware supports LRO functions
 
 * Ethernet MAC node
 
@@ -51,6 +51,7 @@ eth: ethernet@1b100000 {
 	reset-names = "eth";
 	mediatek,ethsys = <&ethsys>;
 	mediatek,pctl = <&syscfg_pctl_a>;
+	mediatek,hwlro;
 	#address-cells = <1>;
 	#size-cells = <0>;
 
-- 
1.9.1
