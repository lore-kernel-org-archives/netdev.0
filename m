From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next 3/3] net: ethernet: mediatek: add dts configuration to enable HW LRO
Date: Tue, 13 Sep 2016 21:54:26 +0800
Message-ID: <1473774866-3156-4-git-send-email-nelson.chang@mediatek.com>
References: <1473774866-3156-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:53966 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750951AbcIMNyi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 09:54:38 -0400
In-Reply-To: <1473774866-3156-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the configuration of HW LRO in the binding document.

Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
---
 Documentation/devicetree/bindings/net/mediatek-net.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index 32eaaca..f43c0d1 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -20,6 +20,7 @@ Required properties:
 - mediatek,ethsys: phandle to the syscon node that handles the port setup
 - mediatek,pctl: phandle to the syscon node that handles the ports slew rate
 	and driver current
+- mediatek,hwlro: set to enable HW LRO functions of PDMA rx rings
 
 Optional properties:
 - interrupt-parent: Should be the phandle for the interrupt controller
@@ -51,6 +52,7 @@ eth: ethernet@1b100000 {
 	reset-names = "eth";
 	mediatek,ethsys = <&ethsys>;
 	mediatek,pctl = <&syscfg_pctl_a>;
+	mediatek,hwlro;
 	#address-cells = <1>;
 	#size-cells = <0>;
 
-- 
1.9.1
