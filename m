From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] Documentation: broadcom-bcmgenet: add better clocks documentation
Date: Fri, 14 Feb 2014 15:21:42 -0800
Message-ID: <1392420102-8785-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>,
	"Mark Rutland" <mark.rutland@arm.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:41255 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbaBNXWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 18:22:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document the required "clocks" phandles and their corresponding
"clock-names" properties for the two clocks used by the GENET hardware
block ("enet" and "enet-wol").

CC: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
index afd31f9..88c3d04 100644
--- a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
+++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
@@ -14,8 +14,11 @@ Required properties:
 - size-cells: should be 1
 
 Optional properties:
-- clocks: When provided, must be two cells, first one is the main GENET clock
-  and the second cell is the Genet Wake-on-LAN clock.
+- clocks: When provided, must be two phandles to the functional clocks nodes
+  of the GENET block. The first phandle is the main GENET clock used during
+  normal operation, while the second phandle is the Wake-on-LAN clock.
+- clock-names: When provided, names of the functional clock phandles, first
+  name should be "enet" and second should be "enet-wol".
 
 - phy-handle: A phandle to a phy node defining the PHY address (as the reg
   property, a single integer), used to describe configurations where a PHY
-- 
1.8.3.2
