From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 5/6] dt-bindings: allow up to three clocks for orion-mdio
Date: Mon, 10 Apr 2017 16:28:25 +0100
Message-ID: <E1cxbEv-0006gY-PO@rmk-PC.armlinux.org.uk>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37700 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753334AbdDJP2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:28:40 -0400
In-Reply-To: <20170410152728.GT17774@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Armada 8040 needs three clocks to be enabled for MDIO accesses to work.
Update the binding to allow the extra clocks to be specified.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 Documentation/devicetree/bindings/net/marvell-orion-mdio.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index ca733ff68ab9..ccdabdcc8618 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -14,7 +14,7 @@ interface.
 
 Optional properties:
 - interrupts: interrupt line number for the SMI error/done interrupt
-- clocks: Phandle to the clock control device and gate bit
+- clocks: phandle for up to three required clocks for the MDIO instance
 
 The child nodes of the MDIO driver are the individual PHY devices
 connected to this MDIO bus. They must have a "reg" property given the
-- 
2.7.4
