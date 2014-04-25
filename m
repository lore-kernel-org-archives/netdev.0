From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/4] Documentation: add Broadcom SYSTEMPORT Device Tree bindings
Date: Thu, 24 Apr 2014 18:08:58 -0700
Message-ID: <1398388140-8003-3-git-send-email-f.fainelli@gmail.com>
References: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:49530 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbaDYBJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 21:09:25 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so2535967pab.39
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 18:09:24 -0700 (PDT)
In-Reply-To: <1398388140-8003-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the Device Tree bindings documentation for the Broadcom SYSTEMPORT
Ethernet MAC controller hardware.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../bindings/net/broadcom-systemport.txt           | 29 ++++++++++++++++++++++
 1 file changed, 29 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-systemport.txt

diff --git a/Documentation/devicetree/bindings/net/broadcom-systemport.txt b/Documentation/devicetree/bindings/net/broadcom-systemport.txt
new file mode 100644
index 000000000000..1b7600e022dd
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/broadcom-systemport.txt
@@ -0,0 +1,29 @@
+* Broadcom BCM7xxx Ethernet Systemport Controller (SYSTEMPORT)
+
+Required properties:
+- compatible: should be one of "brcm,systemport-v1.00" or "brcm,systemport"
+- reg: address and length of the register set for the device.
+- interrupts: interrupts for the device, first cell must be for the the rx
+  interrupts, and the second cell should be for the transmit queues
+- local-mac-address: Ethernet MAC address (48 bits) of this adapter
+- phy-mode: Should be a string describing the PHY interface to the
+  Ethernet switch/PHY, see Documentation/devicetree/bindings/net/ethernet.txt
+- fixed-link: see Documentation/devicetree/bindings/net/fsl-tsec-phy.txt for
+  the property specific details
+
+Optional properties:
+- systemport,num-tier2-arb: number of tier 2 arbiters, an integer
+- systemport,num-tier1-arb: number of tier 1 arbiters, an integer
+- systemport,num-txq: number of HW transmit queues, an integer
+- systemport,num-rxq: number of HW receive queues, an integer
+
+Example:
+ethernet@f04a0000 {
+	compatible = "brcm,systemport-v1.00";
+	reg = <0xf04a0000 0x4650>;
+	local-mac-address = [ 00 11 22 33 44 55 ];
+	fixed-link = <0 1 1000 0 0>;
+	phy-mode = "gmii";
+	interrupts = <0x0 0x16 0x0>,
+		<0x0 0x17 0x0>;
+};
-- 
1.9.1
