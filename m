From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next v2 3/3] net: ethernet: mediatek: remove hwlro property in the device tree
Date: Wed, 5 Oct 2016 20:12:12 +0800
Message-ID: <1475669532-23894-4-git-send-email-nelson.chang@mediatek.com>
References: <1475669532-23894-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:41702 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752238AbcJEMMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 08:12:22 -0400
In-Reply-To: <1475669532-23894-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the proper way to check the hw lro capability is by the chip id,
hwlro property in the device tree should be removed.

Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
---
 Documentation/devicetree/bindings/net/mediatek-net.txt | 2 --
 1 file changed, 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index f095257..c010faf 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -24,7 +24,6 @@ Required properties:
 Optional properties:
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
-- mediatek,hwlro: the capability if the hardware supports LRO functions
 
 * Ethernet MAC node
 
@@ -54,7 +53,6 @@ eth: ethernet@1b100000 {
 	reset-names = "eth";
 	mediatek,ethsys = <&ethsys>;
 	mediatek,pctl = <&syscfg_pctl_a>;
-	mediatek,hwlro;
 	#address-cells = <1>;
 	#size-cells = <0>;
 
-- 
1.9.1
