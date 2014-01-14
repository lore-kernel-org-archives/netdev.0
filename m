From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next v2 1/2] dts: Add a binding for Synopsys emac max-frame-size
Date: Tue, 14 Jan 2014 08:40:08 -0600
Message-ID: <1389710409-14106-2-git-send-email-vbridgers2013@gmail.com>
References: <1389710409-14106-1-git-send-email-vbridgers2013@gmail.com>
Cc: peppe.cavallaro@st.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, dinguyen@altera.com,
	rayagond@vayavyalabs.com, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:56618 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbaANOpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 09:45:16 -0500
In-Reply-To: <1389710409-14106-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds a parameter for the Synopsys 10/100/1000
stmmac Ethernet driver to configure the maximum frame
size supported by the EMAC driver. Synopsys allows the FIFO
sizes to be configured when the cores are built for a particular
device, but do not provide a way for the driver to read
information from the device about the maximum MTU size
supported as limited by the device's FIFO size.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index eba0e5e..26a0ba9 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -30,6 +30,10 @@ Required properties:
 
 Optional properties:
 - mac-address: 6 bytes, mac address
+- snps,max-frame-size:	Maximum frame size permitted. This parameter is useful 
+			since different implementations of the Synopsys MAC may 
+			have different FIFO sizes depending on the selections
+			made in Synopsys Core Consultant.
 
 Examples:
 
@@ -40,5 +44,6 @@ Examples:
 		interrupts = <24 23>;
 		interrupt-names = "macirq", "eth_wake_irq";
 		mac-address = [000000000000]; /* Filled in by U-Boot */
+		snps,max-frame-size = <3800>;
 		phy-mode = "gmii";
 	};
-- 
1.7.9.5
