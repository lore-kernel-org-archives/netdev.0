From: John Crispin <john@phrozen.org>
Subject: [PATCH 1/2] Documentation: devicetree: change the mediatek ethernet compatible string
Date: Wed, 25 Jan 2017 09:20:54 +0100
Message-ID: <1485332455-34743-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, Sean Wang <sean.wang@mediatek.com>,
        devicetree@vger.kernel.org, linux-mediatek@lists.infradead.org,
        John Crispin <john@phrozen.org>
To: Rob Herring <robh+dt@kernel.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:55041 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751367AbdAYJNu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 04:13:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the binding was defined, I was not aware that mt2701 was an earlier
version of the SoC. For sake of consistency, the ethernet driver should
use mt2701 inside the compat string as this is the earliest SoC with the
ethernet core.

The ethernet driver is currently of no real use until we finish and
upstream the DSA driver. There are no users of this binding yet. It should
be safe to fix this now before it is too late and we need to provide
backward compatibility for the mt7623-eth compat string.

Reported-by: Sean Wang <sean.wang@mediatek.com>
Signed-off-by: John Crispin <john@phrozen.org>
---
 Documentation/devicetree/bindings/net/mediatek-net.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index c010faf..c7194e8 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -7,7 +7,7 @@ have dual GMAC each represented by a child node..
 * Ethernet controller node
 
 Required properties:
-- compatible: Should be "mediatek,mt7623-eth"
+- compatible: Should be "mediatek,mt2701-eth"
 - reg: Address and length of the register set for the device
 - interrupts: Should contain the three frame engines interrupts in numeric
 	order. These are fe_int0, fe_int1 and fe_int2.
-- 
1.7.10.4
