From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v2] Documentation: devicetree: revise ethernet device-tree binding about TRGMII
Date: Fri, 23 Sep 2016 14:04:09 +0800
Message-ID: <1474610649-18582-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <john@phrozen.org>,
        <keyhaede@gmail.com>, <objelf@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <davem@davemloft.net>, <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

add phy-mode "trgmii" to
Documentation/devicetree/bindings/net/ethernet.txt

Cc: devicetree@vger.kernel.org
Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 Documentation/devicetree/bindings/net/ethernet.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

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
-- 
1.9.1
