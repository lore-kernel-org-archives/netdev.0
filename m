From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v3 1/4] net: phy: dp83867: Add documentation for optional impedance control
Date: Thu, 6 Oct 2016 10:43:52 +0530
Message-ID: <20161006051355.15947-2-mugunthanvnm@ti.com>
References: <20161006051355.15947-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161006051355.15947-1-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add documention of ti,impedance-control which can be used to
correct MAC impedance mismatch using phy extended registers.

Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
