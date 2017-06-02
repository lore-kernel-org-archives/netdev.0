From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 5/6] dt-bindings: display: amlogic: DT fix s/resets-names/reset-names/
Date: Fri,  2 Jun 2017 14:38:48 +0200
Message-ID: <1496407129-13527-6-git-send-email-geert+renesas@glider.be>
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

Fixes: 8cceda5349377e30 ("dt-bindings: Add bindings for the Amlogic Meson dw-hdmi extension")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
v3:
  - New.
---
 Documentation/devicetree/bindings/display/amlogic,meson-dw-hdmi.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/display/amlogic,meson-dw-hdmi.txt b/Documentation/devicetree/bindings/display/amlogic,meson-dw-hdmi.txt
index 7f040edc16fe6325..a65c890e3170f875 100644
--- a/Documentation/devicetree/bindings/display/amlogic,meson-dw-hdmi.txt
+++ b/Documentation/devicetree/bindings/display/amlogic,meson-dw-hdmi.txt
@@ -43,7 +43,7 @@ Required properties:
   and the Amlogic Meson venci clocks as described in
   Documentation/devicetree/bindings/clock/clock-bindings.txt,
   the clocks are soc specific, the clock-names should be "iahb", "isfr", "venci"
-- resets, resets-names: must have the phandles to the HDMI apb, glue and phy
+- resets, reset-names: must have the phandles to the HDMI apb, glue and phy
   resets as described in :
   Documentation/devicetree/bindings/reset/reset.txt,
   the reset-names should be "hdmitx_apb", "hdmitx", "hdmitx_phy"
-- 
2.7.4
