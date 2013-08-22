From: Boris BREZILLON <b.brezillon@overkiz.com>
Subject: [PATCH 2/2] ARM: at91/dt: define phy available on sama5d3 mother board
Date: Thu, 22 Aug 2013 17:58:29 +0200
Message-ID: <1377187109-21981-1-git-send-email-b.brezillon@overkiz.com>
References: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Boris BREZILLON <b.brezillon@overkiz.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch describe the phy used on atmel sama5d3 mother board:
 - phy address
 - phy interrupt pin

Signed-off-by: Boris BREZILLON <b.brezillon@overkiz.com>
---
 arch/arm/boot/dts/sama5d3xmb.dtsi |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/arm/boot/dts/sama5d3xmb.dtsi b/arch/arm/boot/dts/sama5d3xmb.dtsi
index 8a9e05d..e9521d5 100644
--- a/arch/arm/boot/dts/sama5d3xmb.dtsi
+++ b/arch/arm/boot/dts/sama5d3xmb.dtsi
@@ -81,6 +81,14 @@
 
 			macb1: ethernet@f802c000 {
 				phy-mode = "rmii";
+
+				#address-cells = <1>;
+				#size-cells = <0>;
+				phy0: ethernet-phy@0 {
+					interrupt-parent = <&pioE>;
+					interrupts = <30 IRQ_TYPE_EDGE_FALLING>;
+					reg = <1>;
+				};
 			};
 
 			pinctrl@fffff200 {
-- 
1.7.9.5
