From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 12/15] net: davinci_mdio: document missed "ti,am4372-mdio" compat string
Date: Wed, 15 Jun 2016 14:56:00 +0300
Message-ID: <20160615115603.4897-13-grygorii.strashko@ti.com>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615115603.4897-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Document missed "ti,am4372-mdio" compat string used for TI am437x SoC
(am4372.dtsi).

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/davinci-mdio.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/davinci-mdio.txt b/Documentation/devicetree/bindings/net/davinci-mdio.txt
index 0369e25..f2bba50 100644
--- a/Documentation/devicetree/bindings/net/davinci-mdio.txt
+++ b/Documentation/devicetree/bindings/net/davinci-mdio.txt
@@ -2,7 +2,8 @@ TI SoC Davinci/Keystone2 MDIO Controller Device Tree Bindings
 ---------------------------------------------------
 
 Required properties:
-- compatible		: Should be "ti,davinci_mdio" or "ti,keystone_mdio"
+- compatible		: Should be "ti,davinci_mdio", "ti,keystone_mdio",
+			  "ti,am4372-mdio"
 - reg			: physical base address and size of the davinci mdio
 			  registers map
 - bus_freq		: Mdio Bus frequency
-- 
2.8.4
