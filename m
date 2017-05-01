From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v5 04/20] dt-bindings: syscon: Add DT bindings documentation for Allwinner syscon
Date: Mon,  1 May 2017 14:45:04 +0200
Message-ID: <20170501124520.3769-5-clabbe.montjoie@gmail.com>
References: <20170501124520.3769-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36000 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424612AbdEAMsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 08:48:12 -0400
In-Reply-To: <20170501124520.3769-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds documentation for Device-Tree bindings for the
syscon present in allwinner devices.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 .../devicetree/bindings/misc/allwinner,syscon.txt     | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/misc/allwinner,syscon.txt

diff --git a/Documentation/devicetree/bindings/misc/allwinner,syscon.txt b/Documentation/devicetree/bindings/misc/allwinner,syscon.txt
new file mode 100644
index 0000000..cb57691
--- /dev/null
+++ b/Documentation/devicetree/bindings/misc/allwinner,syscon.txt
@@ -0,0 +1,19 @@
+* Allwinner sun8i system controller
+
+This file describes the bindings for the system controller present in
+Allwinner SoC H3, A83T and A64.
+The principal function of this syscon is to control EMAC PHY choice and
+config.
+
+Required properties for the system controller:
+- reg: address and length of the register for the device.
+- compatible: should be "syscon" and one of the following string:
+		"allwinner,sun8i-h3-system-controller"
+		"allwinner,sun50i-a64-system-controller"
+		"allwinner,sun8i-a83t-system-controller"
+
+Example:
+syscon: syscon@1c00000 {
+	compatible = "allwinner,sun8i-h3-system-controller", "syscon";
+	reg = <0x01c00000 0x1000>;
+};
-- 
2.10.2
