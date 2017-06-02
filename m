From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 2/6] arm64: dts: lg1313: DT fix s/#interrupts-cells/#interrupt-cells/
Date: Fri,  2 Jun 2017 14:38:45 +0200
Message-ID: <1496407129-13527-3-git-send-email-geert+renesas@glider.be>
References: <1496407129-13527-1-git-send-email-geert+renesas@glider.be>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        dri-devel@lists.freedesktop.org, linux-amlogic@lists.infradead.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: David Airlie <airlied@linux.ie>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Chanho Min <chanho.min@lge.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496407129-13527-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Chanho Min <chanho.min@lge.com>
---
v3:
  - Add Acked-by,

v2:
  - New.
---
 arch/arm64/boot/dts/lg/lg1313.dtsi | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/boot/dts/lg/lg1313.dtsi b/arch/arm64/boot/dts/lg/lg1313.dtsi
index e703e1149c757082..abb2162228e82d39 100644
--- a/arch/arm64/boot/dts/lg/lg1313.dtsi
+++ b/arch/arm64/boot/dts/lg/lg1313.dtsi
@@ -123,7 +123,7 @@
 	amba {
 		#address-cells = <2>;
 		#size-cells = <1>;
-		#interrupts-cells = <3>;
+		#interrupt-cells = <3>;
 
 		compatible = "simple-bus";
 		interrupt-parent = <&gic>;
-- 
2.7.4
