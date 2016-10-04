From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 1/4] net: phy: dp83867: Add documentation for optional
 impedance control
Date: Tue, 4 Oct 2016 18:26:04 +0530
Message-ID: <20161004125607.10569-2-mugunthanvnm@ti.com>
References: <20161004125607.10569-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Mugunthan V N <mugunthanvnm@ti.com>,
 Tony Lindgren <tony@atomide.com>, Sekhar Nori <nsekhar@ti.com>,
 linux-kernel@vger.kernel.org, Russell King <linux@armlinux.org.uk>,
 Rob Herring <robh+dt@kernel.org>, linux-omap@vger.kernel.org,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161004125607.10569-1-mugunthanvnm@ti.com>
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
 Documentation/devicetree/bindings/net/ti,dp83867.txt | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
index 5d21141..85bf945 100644
--- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
+++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
@@ -9,6 +9,18 @@ Required properties:
 	- ti,fifo-depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83867.h
 		for applicable values
 
+Optional property:
+	- ti,min-output-impedance - MAC Interface Impedance control to set
+				    the programmable output impedance to
+				    minimum value (35 ohms).
+	- ti,max-output-impedance - MAC Interface Impedance control to set
+				    the programmable output impedance to
+				    maximum value (70 ohms).
+
+Note: ti,min-output-impedance and ti,max-output-impedance are mutually
+      exclusive. When both properties are present ti,max-output-impedance
+      takes precedence.
+
 Default child nodes are standard Ethernet PHY device
 nodes as described in Documentation/devicetree/bindings/net/phy.txt
 
-- 
2.10.0.372.g6fe1b14
