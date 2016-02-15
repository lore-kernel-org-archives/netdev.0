From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] ravb: Update DT binding example for final CPG/MSSR bindings
Date: Mon, 15 Feb 2016 13:41:31 +0100
Message-ID: <1455540091-23427-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	linux-renesas-soc@vger.kernel.org, netdev@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from laurent.telenet-ops.be ([195.130.137.89]:34428 "EHLO
	laurent.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705AbcBOMld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 07:41:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The example in the DT binding documentation uses the preliminary DT
bindings for the r8a7795 MSTP clocks, which never went upstream.
Update the example to use the DT bindings for the upstream Clock Pulse
Generator / Module Standby and Software Reset hardware block.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 Documentation/devicetree/bindings/net/renesas,ravb.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
index 81a9f9e6b45ff85c..c8ac222eac67a0c3 100644
--- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
+++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -82,8 +82,8 @@ Example:
 				  "ch16", "ch17", "ch18", "ch19",
 				  "ch20", "ch21", "ch22", "ch23",
 				  "ch24";
-		clocks = <&mstp8_clks R8A7795_CLK_ETHERAVB>;
-		power-domains = <&cpg_clocks>;
+		clocks = <&cpg CPG_MOD 812>;
+		power-domains = <&cpg>;
 		phy-mode = "rgmii-id";
 		phy-handle = <&phy0>;
 
-- 
1.9.1
