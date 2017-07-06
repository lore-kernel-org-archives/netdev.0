From: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v1 1/1] dt-binding: ptp: Add SoC compatibility strings for dte ptp clock
Date: Thu,  6 Jul 2017 10:37:57 -0700
Message-ID: <1499362677-28579-1-git-send-email-arun.parameswaran@broadcom.com>
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add SoC specific compatibility strings to the Broadcom DTE
based PTP clock binding document.

Fixed the document heading and node name.

Fixes: 80d6076140b2 ("dt-binding: ptp: add bindings document for dte based ptp clock")
Signed-off-by: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
index 07590bc..7c04e22 100644
--- a/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
+++ b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
@@ -1,13 +1,20 @@
-* Broadcom Digital Timing Engine(DTE) based PTP clock driver
+* Broadcom Digital Timing Engine(DTE) based PTP clock
 
 Required properties:
-- compatible: should be "brcm,ptp-dte"
+- compatible: should contain the core compatibility string
+              and the SoC compatibility string. The SoC
+              compatibility string is to handle SoC specific
+              hardware differences.
+              Core compatibility string:
+                 "brcm,ptp-dte"
+              SoC compatibility strings:
+                 "brcm,iproc-ptp-dte" - for iproc based SoC's
 - reg: address and length of the DTE block's NCO registers
 
 Example:
 
-ptp_dte: ptp_dte@180af650 {
-	compatible = "brcm,ptp-dte";
+ptp: ptp-dte@180af650 {
+	compatible = "brcm,iproc-ptp-dte", "brcm,ptp-dte";
 	reg = <0x180af650 0x10>;
 	status = "okay";
 };
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
