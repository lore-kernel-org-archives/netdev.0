From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/3] net: phy: dp83867: Add documentation for
 optional impedance control
Date: Wed, 20 Jul 2016 20:26:12 +0530
Message-ID: <20160720145614.13132-2-mugunthanvnm@ti.com>
References: <20160720145614.13132-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Mugunthan V N <mugunthanvnm@ti.com>,
 Tony Lindgren <tony@atomide.com>, Sekhar Nori <nsekhar@ti.com>,
 Russell King <linux@armlinux.org.uk>, linux-kernel@vger.kernel.org,
 Rob Herring <robh+dt@kernel.org>, linux-omap@vger.kernel.org,
 "David S . Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160720145614.13132-1-mugunthanvnm@ti.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Add documention of ti,impedance-control which can be used to
correct MAC impedance mismatch using phy extended registers.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/ti,dp83867.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
index 5d21141..531ea3c5 100644
--- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
+++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
@@ -9,6 +9,13 @@ Required properties:
 	- ti,fifo-depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83867.h
 		for applicable values
 
+Optional property:
+	- ti,impedance-control - MAC Interface Impedance control to vary the
+				 output impedance with an approximate range
+				 from 35-70 ohms in 32 steps. Value range can
+				 be 0x0 to 0x1f. Lowest impedance value is
+				 0x1f and highest impedance being 0x0.
+
 Default child nodes are standard Ethernet PHY device
 nodes as described in Documentation/devicetree/bindings/net/phy.txt
 
-- 
2.9.2.368.g08bb350
