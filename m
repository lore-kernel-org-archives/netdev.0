From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 3/3] net: ethernet: mediatek: add the dts property to set if TRGMII supported on GMAC0
Date: Tue, 20 Sep 2016 15:59:20 +0800
Message-ID: <1474358360-29901-4-git-send-email-sean.wang@mediatek.com>
References: <1474358360-29901-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:1281 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S932277AbcITH7h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 03:59:37 -0400
In-Reply-To: <1474358360-29901-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

Add the dts property for the capability if TRGMII supported on GAMC0

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 Documentation/devicetree/bindings/net/mediatek-net.txt | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index 6103e55..32f79d8 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -31,7 +31,10 @@ Optional properties:
 Required properties:
 - compatible: Should be "mediatek,eth-mac"
 - reg: The number of the MAC
-- phy-handle: see ethernet.txt file in the same directory.
+- phy-handle: see ethernet.txt file in the same directory and
+	the additional phy-mode "tgrmii" is provided in order to connect
+	with the internal switch MT7530 which is only applicable when reg
+	is equal to 0.
 
 Example:
 
-- 
1.9.1
