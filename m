From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 19/22] dt/bindings: add micrel,rmii_ref_clk_sel_25_mhz to eth-phy binding
Date: Tue, 11 Nov 2014 18:37:37 +0100
Message-ID: <1415727460-20417-20-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>, devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add "micrel,rmii_ref_clk_sel_25_mhz" to Micrel ethernet PHY binding
documentation.

Cc: devicetree@vger.kernel.org
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 Documentation/devicetree/bindings/net/micrel.txt | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
index a1bab5eaae02..9b08dd6551dd 100644
--- a/Documentation/devicetree/bindings/net/micrel.txt
+++ b/Documentation/devicetree/bindings/net/micrel.txt
@@ -19,6 +19,11 @@ Optional properties:
 
               See the respective PHY datasheet for the mode values.
 
+ - micrel,rmii_ref_clk_sel_25_mhz: rmii_ref_clk_sel bit selects 25 MHz mode
+
+		Whether 25 MHz (rather than 50 Mhz) clock mode is selected
+		when the rmii_ref_clk_sel bit is set.
+
  - clocks, clock-names: contains clocks according to the common clock bindings.
 
               supported clocks:
-- 
2.0.4
