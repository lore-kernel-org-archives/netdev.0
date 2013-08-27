From: Boris BREZILLON <b.brezillon@overkiz.com>
Subject: [PATCH v2] ARM: at91/dt: fix phy address in sama5xmb to match the reg property
Date: Tue, 27 Aug 2013 14:41:53 +0200
Message-ID: <1377607313-21331-1-git-send-email-b.brezillon@overkiz.com>
References: <1377605096-20903-1-git-send-email-b.brezillon@overkiz.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Boris BREZILLON <b.brezillon@overkiz.com>
To: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377605096-20903-1-git-send-email-b.brezillon@overkiz.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix phy0 address to match the reg property defined in phy0 node.

Signed-off-by: Boris BREZILLON <b.brezillon@overkiz.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
Changes since v1:
 - better commit message

 arch/arm/boot/dts/sama5d3xmb.dtsi |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/sama5d3xmb.dtsi b/arch/arm/boot/dts/sama5d3xmb.dtsi
index e9521d5..dba739b 100644
--- a/arch/arm/boot/dts/sama5d3xmb.dtsi
+++ b/arch/arm/boot/dts/sama5d3xmb.dtsi
@@ -84,7 +84,7 @@
 
 				#address-cells = <1>;
 				#size-cells = <0>;
-				phy0: ethernet-phy@0 {
+				phy0: ethernet-phy@1 {
 					interrupt-parent = <&pioE>;
 					interrupts = <30 IRQ_TYPE_EDGE_FALLING>;
 					reg = <1>;
-- 
1.7.9.5
