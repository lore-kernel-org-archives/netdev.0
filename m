From: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 net-next 3/3] bindings: ethernet: macb: Add optional caps properties
Date: Tue,  8 Dec 2015 14:52:06 +0100
Message-ID: <1449582726-6148-4-git-send-email-narmstrong@baylibre.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
 <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
To: nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joshc-acOepvfBmUk@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449582726-6148-1-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add generic caps properties to the binding in order to support
future macb/gem implementations with the generic macb compatible form.

Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
---
 Documentation/devicetree/bindings/net/macb.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5d7976..891c72e 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -19,6 +19,16 @@ Required properties:
 	Optional elements: 'tx_clk'
 - clocks: Phandles to input clocks.
 
+Optional properties:
+- cdns,usrio-has-clken: Boolean; The USRIO register has an clock-enable bit.
+- cdns,usrio-default-mii: Boolean; The USRIO register defaults to MII mode.
+- cdns,usrio-disabled: Boolean; The USRIO register is not implemented.
+- cdns,no-gigabit-half: Boolean; The MAC does not support 1000/Half link mode.
+- cdns,gem-sg-disabled: Boolean; The MAC does not support Scatter-Gather mode.
+- cdns,gem-has-gigabit: Boolean; The MAC supports Gigabit Ethernet.
+- cdns,dma-burst-length: Should countain the DMA burst length.
+- cdns,jumbo-max-length: Should countain the maximum Jumbo frame length.
+
 Examples:
 
 	macb0: ethernet@fffc4000 {
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
