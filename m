From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 11/12] Documentation: devicetree: update dsa binding with optional properties
Date: Tue,  5 Aug 2014 15:31:45 -0700
Message-ID: <1407277906-19989-12-git-send-email-f.fainelli@gmail.com>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linville@tuxdriver.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:46421 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbaHEWcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 18:32:18 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so2201385pad.39
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 15:32:18 -0700 (PDT)
In-Reply-To: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation for a bunch of new optional properties described in
ethernet.txt and fixed-link.txt, this includes: 'phy-handle', 'phy-mode'
and the 'fixed-link' subnode.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 49f4f7ae3f51..6192f9a7aa89 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -39,6 +39,22 @@ Optionnal property:
 			  This property is only used when switches are being
 			  chained/cascaded together.
 
+- phy-handle		: Phandle to a PHY on an external MDIO bus, not the
+			  switch internal one. See
+			  Documentation/devicetree/bindings/net/ethernet.txt
+			  for details.
+
+- phy-mode		: String representing the connection to the designeted
+			  PHY node specified by the 'phy-handle' property. See
+			  Documentation/devicetree/bindings/net/ethernet.txt
+			  for details.
+
+Optionnal subnodes:
+- fixed-link		: Fixed-link subnode describing a link to a non-MDIO
+			  managed entity. See
+			  Documentation/devicetree/bindings/net/fixed-link.txt
+			  for details.
+
 Example:
 
 	dsa@0 {
@@ -58,6 +74,7 @@ Example:
 			port@0 {
 				reg = <0>;
 				label = "lan1";
+				phy-handle = <&phy0>;
 			};
 
 			port@1 {
-- 
1.9.1
