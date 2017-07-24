From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 12/18] Documentation/bindings: net: marvell-pp2: add the interrupt-names
Date: Mon, 24 Jul 2017 15:48:42 +0200
Message-ID: <20170724134848.19330-13-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47392 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755848AbdGXNuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:07 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An interrupt-names property can be used in the PPv2 port description
bindings when more than a single interrupt (for rx) is used. Document
this new optional property.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 Documentation/devicetree/bindings/net/marvell-pp2.txt | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index 18ec66e51b0a..553aadceeeee 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -42,6 +42,9 @@ Optional properties (port):
 - phy: a phandle to a phy node defining the PHY address (as the reg
   property, a single integer).
 - marvell,system-controller: a phandle to the system controller.
+- interrupt-names: if more than a single interrupt for rx is given, must
+                   be the name associated to the interrupts listed. Valid
+                   names are: "rx-shared", "link".
 
 Example for marvell,armada-375-pp2:
 
@@ -82,18 +85,21 @@ cpm_ethernet: ethernet@0 {
 
 	eth0: eth0 {
 		interrupts = <GIC_SPI 37 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "rx-shared";
 		port-id = <0>;
 		gop-port-id = <0>;
 	};
 
 	eth1: eth1 {
 		interrupts = <GIC_SPI 38 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "rx-shared";
 		port-id = <1>;
 		gop-port-id = <2>;
 	};
 
 	eth2: eth2 {
 		interrupts = <GIC_SPI 39 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "rx-shared";
 		port-id = <2>;
 		gop-port-id = <3>;
 	};
-- 
2.13.3
