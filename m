From: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: [net-next PATCH v2 1/3] devicetree: Add compatible string for Zynq Ultrascale+ MPSoC
Date: Mon, 4 May 2015 13:22:38 +0530
Message-ID: <a6575a7b-9327-4e40-95b7-2ad4b356b493@BY2FFO11OLC006.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add "cdns,zynqmp-gem" to be used for Zynq Ultrascale+ MPSoC.

Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
---

v2:
Updated SoC name

---
 Documentation/devicetree/bindings/net/macb.txt |    1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index ba19d67..8ec5fdf 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -9,6 +9,7 @@ Required properties:
   the Cadence GEM, or the generic form: "cdns,gem".
   Use "cdns,sama5d3-gem" for the Gigabit IP available on Atmel sama5d3 SoCs.
   Use "cdns,sama5d4-gem" for the Gigabit IP available on Atmel sama5d4 SoCs.
+  Use "cdns,zynqmp-gem" for Zynq Ultrascale+ MPSoC.
 - reg: Address and length of the register set for the device
 - interrupts: Should contain macb interrupt
 - phy-mode: See ethernet.txt file in the same directory.
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
