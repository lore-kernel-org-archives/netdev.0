From: Arun Parameswaran <arun.parameswaran@broadcom.com>
Subject: [PATCH v1 1/2] dt-binding: ptp: add bindings document for dte based ptp clock
Date: Mon, 12 Jun 2017 13:26:00 -0700
Message-ID: <1497299161-6458-2-git-send-email-arun.parameswaran@broadcom.com>
References: <1497299161-6458-1-git-send-email-arun.parameswaran@broadcom.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
        Arun Parameswaran <arun.parameswaran@broadcom.com>
To: Richard Cochran <richardcochran@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497299161-6458-1-git-send-email-arun.parameswaran@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device tree binding documentation for the Broadcom DTE
PTP clock driver.

Signed-off-by: Arun Parameswaran <arun.parameswaran@broadcom.com>
---
 Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt | 13 +++++++++++++
 1 file changed, 13 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt

diff --git a/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
new file mode 100644
index 0000000..07590bc
--- /dev/null
+++ b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
@@ -0,0 +1,13 @@
+* Broadcom Digital Timing Engine(DTE) based PTP clock driver
+
+Required properties:
+- compatible: should be "brcm,ptp-dte"
+- reg: address and length of the DTE block's NCO registers
+
+Example:
+
+ptp_dte: ptp_dte@180af650 {
+	compatible = "brcm,ptp-dte";
+	reg = <0x180af650 0x10>;
+	status = "okay";
+};
-- 
1.9.1
