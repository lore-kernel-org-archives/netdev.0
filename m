From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next v6 1/2] dts: Add a binding for Synopsys emac max-frame-size
Date: Mon, 20 Jan 2014 05:39:00 -0600
Message-ID: <1390217941-22967-2-git-send-email-vbridgers2013@gmail.com>
References: <1390217941-22967-1-git-send-email-vbridgers2013@gmail.com>
Cc: peppe.cavallaro@st.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, dinguyen@altera.com,
	rayagond@vayavyalabs.com, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:38195 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaATLoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 06:44:06 -0500
In-Reply-To: <1390217941-22967-1-git-send-email-vbridgers2013@gmail.com>
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
V6: respin for updated net-next
V5: simplify comment on use of max-frame-size
V4: add comments to explain use of max-frame-size with respect
    to inconsistent definition and use in the ePAPR v1.1 spec
V3: change snps,max-frame-size to max-frame-size
V2: change snps,max-mtu to snps,max-frame-size
---
 Documentation/devicetree/bindings/net/stmmac.txt |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index aefb639..9d92d42 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -32,6 +32,8 @@ Optional properties:
 - resets: Should contain a phandle to the STMMAC reset signal, if any
 - reset-names: Should contain the reset signal name "stmmaceth", if a
 	reset phandle is given
+- max-frame-size:	Maximum Transfer Unit (IEEE defined MTU), rather
+			than the maximum frame size.
 
 Examples:
 
@@ -42,5 +44,6 @@ Examples:
 		interrupts = <24 23>;
 		interrupt-names = "macirq", "eth_wake_irq";
 		mac-address = [000000000000]; /* Filled in by U-Boot */
+		max-frame-size = <3800>;
 		phy-mode = "gmii";
 	};
-- 
1.7.9.5
