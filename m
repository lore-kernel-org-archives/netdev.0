From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH v5 2/7] binding: Make "mdio-parent-bus" property from mandatory to optional
Date: Fri, 10 Jun 2016 11:03:46 +0530
Message-ID: <1465536831-13023-3-git-send-email-pramod.kumar@broadcom.com>
References: <1465536831-13023-1-git-send-email-pramod.kumar@broadcom.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pramod Kumar <pramod.kumar@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465536831-13023-1-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change "mdio-parent-bus" from mandatory section to optional
as it won't be required by integrated MDIO multiplexer
which has bus selection and mdio transaction generation logic,
integrated inside.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Rob Herring <robh@kernel.org>
---
 Documentation/devicetree/bindings/net/mdio-mux.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/mdio-mux.txt b/Documentation/devicetree/bindings/net/mdio-mux.txt
index 491f5bd..f58571f 100644
--- a/Documentation/devicetree/bindings/net/mdio-mux.txt
+++ b/Documentation/devicetree/bindings/net/mdio-mux.txt
@@ -5,11 +5,12 @@ numbered uniquely in a device dependent manner.  The nodes for an MDIO
 bus multiplexer/switch will have one child node for each child bus.
 
 Required properties:
-- mdio-parent-bus : phandle to the parent MDIO bus.
 - #address-cells = <1>;
 - #size-cells = <0>;
 
 Optional properties:
+- mdio-parent-bus : phandle to the parent MDIO bus.
+
 - Other properties specific to the multiplexer/switch hardware.
 
 Required properties for child nodes:
-- 
1.9.1
