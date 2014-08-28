From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 12/13] Documentation: devicetree: update dsa binding with optional properties
Date: Wed, 27 Aug 2014 17:04:57 -0700
Message-ID: <1409184298-1793-13-git-send-email-f.fainelli@gmail.com>
References: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:39368 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965649AbaH1AGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 20:06:16 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so117983pac.5
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 17:06:15 -0700 (PDT)
In-Reply-To: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation for a bunch of new optional properties described in
ethernet.txt and fixed-link.txt, this includes: 'phy-handle', 'phy-mode'
and the 'fixed-link' subnode.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v5:
- fix typos spotted by Sergei

 Documentation/devicetree/bindings/net/dsa/dsa.txt | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 49f4f7ae3f51..a62c889aafca 100644
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
+- phy-mode		: String representing the connection to the designated
+			  PHY node specified by the 'phy-handle' property. See
+			  Documentation/devicetree/bindings/net/ethernet.txt
+			  for details.
+
+Optional subnodes:
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
