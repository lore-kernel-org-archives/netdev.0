From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 13/15] net: davinci_mdio: introduce "ti,cpsw-mdio" compat string
Date: Fri, 24 Jun 2016 21:23:53 +0300
Message-ID: <20160624182355.23515-14-grygorii.strashko@ti.com>
References: <20160624182355.23515-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624182355.23515-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce "ti,cpsw-mdio" compatible string for Davinci MDIO, because
it's required to distinguish the case when MDIO is part of TI CPSW to
enable features supported by TI CPSW (for example, enable PM
management).

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/davinci-mdio.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/davinci-mdio.txt b/Documentation/devicetree/bindings/net/davinci-mdio.txt
index b6a4f48..621156c 100644
--- a/Documentation/devicetree/bindings/net/davinci-mdio.txt
+++ b/Documentation/devicetree/bindings/net/davinci-mdio.txt
@@ -4,6 +4,7 @@ TI SoC Davinci/Keystone2 MDIO Controller Device Tree Bindings
 Required properties:
 - compatible		: Should be "ti,davinci_mdio"
 			  and "ti,keystone_mdio" for Keystone 2 SoCs
+			  and "ti,cpsw-mdio" for am335x, am472x, am57xx/dra7, dm814x SoCs
 			  and "ti,am4372-mdio" for am472x SoC
 - reg			: physical base address and size of the davinci mdio
 			  registers map
-- 
2.9.0
