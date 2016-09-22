From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] Documentation: devicetree: revise ethernet device-tree binding about TRGMII
Date: Fri, 23 Sep 2016 00:16:36 +0800
Message-ID: <1474560996-20863-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <devicetree@vger.kernel.org>,
        <keyhaede@gmail.com>, <objelf@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <davem@davemloft.net>, <sergei.shtylyov@cogentembedded.com>,
        <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:63411 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756411AbcIVQQo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 12:16:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

fix typo in mediatek-net.txt and add phy-mode "trgmii" to ethernet.txt

Cc: devicetree@vger.kernel.org
Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 Documentation/devicetree/bindings/net/ethernet.txt     | 4 ++--
 Documentation/devicetree/bindings/net/mediatek-net.txt | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 5d88f37..e1d7681 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -11,8 +11,8 @@ The following properties are common to the Ethernet controllers:
   the maximum frame size (there's contradiction in ePAPR).
 - phy-mode: string, operation mode of the PHY interface; supported values are
   "mii", "gmii", "sgmii", "qsgmii", "tbi", "rev-mii", "rmii", "rgmii", "rgmii-id",
-  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii"; this is now a de-facto
-  standard property;
+  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii", "trgmii"; this is now a
+  de-facto standard property;
 - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
 - phy-handle: phandle, specifies a reference to a node representing a PHY
   device; this property is described in ePAPR and so preferred;
diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index bae848e..da05f8b 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -34,7 +34,7 @@ Required properties:
 - phy-handle: see ethernet.txt file in the same directory and
 	the phy-mode "trgmii" required being provided when reg
 	is equal to 0 and the MAC uses fixed-link to connect
-	with inernal switch such as MT7530.
+	with internal switch such as MT7530.
 
 Example:
 
-- 
1.9.1
