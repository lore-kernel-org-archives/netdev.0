From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 1/6] arm64: dts: lg1312: DT fix s/#interrupts-cells/#interrupt-cells/
Date: Fri,  2 Jun 2017 14:38:44 +0200
Message-ID: <1496407129-13527-2-git-send-email-geert+renesas@glider.be>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:34160 "EHLO
        baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdFBMjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 08:39:10 -0400
In-Reply-To: <1496407129-13527-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Rob Herring <robh@kernel.org>
Acked-by: Chanho Min <chanho.min@lge.com>
---
v3:
  - Add Acked-by,

v2:
  - Add Acked-by,
  - Rebased.
---
 arch/arm64/boot/dts/lg/lg1312.dtsi | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/boot/dts/lg/lg1312.dtsi b/arch/arm64/boot/dts/lg/lg1312.dtsi
index fbafa24cd5335b90..647606a83c517448 100644
--- a/arch/arm64/boot/dts/lg/lg1312.dtsi
+++ b/arch/arm64/boot/dts/lg/lg1312.dtsi
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
