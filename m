From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] dt-bindings: net: don't confuse with generic PHY property
Date: Thu,  7 Sep 2017 11:09:59 +0300
Message-ID: <2e201cc1cff4fad372f589c83c4c438b3dccbadf.1504771799.git.baruch@tkos.co.il>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Baruch Siach <baruch@tkos.co.il>
To: "David S. Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:47751 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754124AbdIGIKc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 04:10:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This complements commit 9a94b3a4bd (dt-binding: phy: don't confuse with
Ethernet phy properties).

The generic PHY 'phys' property sometime appears in the same node with
the Ethernet PHY 'phy' or 'phy-handle' properties. Add a warning in
ethernet.txt to reduce confusion.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 Documentation/devicetree/bindings/net/ethernet.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 7da86f22a13b..2974e63ba311 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -1,5 +1,9 @@
 The following properties are common to the Ethernet controllers:
 
+NOTE: All 'phy*' properties documented below are Ethernet specific. For the
+generic PHY 'phys' property, see
+Documentation/devicetree/bindings/phy/phy-bindings.txt.
+
 - local-mac-address: array of 6 bytes, specifies the MAC address that was
   assigned to the network device;
 - mac-address: array of 6 bytes, specifies the MAC address that was last used by
-- 
2.14.1
