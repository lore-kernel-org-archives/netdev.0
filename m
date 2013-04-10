From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH] net: mvmdio: add clocks property to binding documentation
Date: Wed, 10 Apr 2013 19:36:29 +0200
Message-ID: <1365615391-26244-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch "net: mvmdio: get and enable optional clock" was missing an
update of the corresponding device tree binding documentation. This
patch adds the clocks property to mvmdio binding documentation.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Rob Landley <rob@landley.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Florian Fainelli <florian@openwrt.org>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 Documentation/devicetree/bindings/net/marvell-orion-mdio.txt |    1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index 052b5f2..9417e54 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -11,6 +11,7 @@ Required properties:
 
 Optional properties:
 - interrupts: interrupt line number for the SMI error/done interrupt
+- clocks: Phandle to the clock control device and gate bit
 
 The child nodes of the MDIO driver are the individual PHY devices
 connected to this MDIO bus. They must have a "reg" property given the
-- 
1.7.10.4
