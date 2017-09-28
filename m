From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 1/4] dt-bindings: net: ravb: Document optional reset-gpios property
Date: Thu, 28 Sep 2017 17:53:31 +0200
Message-ID: <1506614014-4398-2-git-send-email-geert+renesas@glider.be>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from andre.telenet-ops.be ([195.130.132.53]:49728 "EHLO
        andre.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdI1Pxy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 11:53:54 -0400
In-Reply-To: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The optional "reset-gpios" property (part of the generic MDIO bus
properties) lets us describe the GPIO used for resetting the Ethernet
PHY.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 Documentation/devicetree/bindings/net/renesas,ravb.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
index c902261893b913f5..4a6ec1ba32d0bf16 100644
--- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
+++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -52,6 +52,7 @@ Optional properties:
 			 AVB_LINK signal.
 - renesas,ether-link-active-low: boolean, specify when the AVB_LINK signal is
 				 active-low instead of normal active-high.
+- reset-gpios: see mdio.txt in the same directory.
 
 Example:
 
@@ -99,6 +100,7 @@ Example:
 		pinctrl-0 = <&ether_pins>;
 		pinctrl-names = "default";
 		renesas,no-ether-link;
+		reset-gpios = <&gpio2 10 GPIO_ACTIVE_LOW>;
 		#address-cells = <1>;
 		#size-cells = <0>;
 
-- 
2.7.4
