From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 1/2] powerpc/85xx: add the Fman device tree template include files
Date: Fri, 10 Aug 2012 17:31:35 -0500
Message-ID: <1344637896-14267-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	Scott Wood <scottwood@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	<ddaney.cavm@gmail.com>, <linuxppc-dev@ozlabs.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:49575 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752755Ab2HJWbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 18:31:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce the template include files for the Freecale Frame Manager (Fman).
An SOC can have up to two Fman devices, and each Fman can have up to
five 1G Ethernet MACs and one 10G Ethernet MAC.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 arch/powerpc/boot/dts/fsl/qoriq-fman-0-10g-0.dtsi |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-0.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-1.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-2.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-3.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-4.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-0.dtsi       |  140 +++++++++++++++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-1-10g-0.dtsi |   54 ++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-0.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-1.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-2.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-3.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-4.dtsi  |   63 +++++++++
 arch/powerpc/boot/dts/fsl/qoriq-fman-1.dtsi       |  140 +++++++++++++++++++++
 14 files changed, 1027 insertions(+), 0 deletions(-)
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-0-10g-0.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-0.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-1.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-2.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-3.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-4.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-0.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-1-10g-0.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-0.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-1.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-2.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-3.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-4.dtsi
 create mode 100644 arch/powerpc/boot/dts/fsl/qoriq-fman-1.dtsi

diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-0-10g-0.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-10g-0.dtsi
new file mode 100644
index 0000000..cc6bad3
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-10g-0.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 10g port #0 device tree stub [ controller @ offset 0x400000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@400000 {
+	fman0_10g_rx0: port@90000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-10g-rx";
+		reg = <0x90000 0x1000>;
+	};
+
+	fman0_10g_tx0: port@b0000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-10g-tx";
+		reg = <0xb0000 0x1000>;
+		fsl,qman-channel-id = <0x40>;
+	};
+
+	ethernet@f0000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-10g-mac";
+		reg = <0xf0000 0x1000>;
+		fsl,port-handles = <&fman0_10g_rx0 &fman0_10g_tx0>;
+	};
+
+	xmdio0: mdio@f1000 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-xmdio";
+		reg = <0xf1000 0x1000>;
+		interrupts = <100 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-0.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-0.dtsi
new file mode 100644
index 0000000..d6dca2c
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-0.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #0 device tree stub [ controller @ offset 0x400000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@400000 {
+	fman0_rx0: port@88000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x88000 0x1000>;
+	};
+
+	fman0_tx0: port@a8000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xa8000 0x1000>;
+	};
+
+	ethernet@e0000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe0000 0x1000>;
+		fsl,port-handles = <&fman0_rx0 &fman0_tx0>;
+		ptimer-handle = <&ptp_timer0>;
+	};
+
+	mdio0: mdio@e1120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-mdio";
+		reg = <0xe1120 0xee0>;
+		interrupts = <100 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-1.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-1.dtsi
new file mode 100644
index 0000000..75e3dd6
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-1.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #1 device tree stub [ controller @ offset 0x400000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@400000 {
+	fman0_rx1: port@89000 {
+		cell-index = <1>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x89000 0x1000>;
+	};
+
+	fman0_tx1: port@a9000 {
+		cell-index = <1>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xa9000 0x1000>;
+	};
+
+	ethernet@e2000 {
+		cell-index = <1>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe2000 0x1000>;
+		fsl,port-handles = <&fman0_rx1 &fman0_tx1>;
+		ptimer-handle = <&ptp_timer0>;
+	};
+
+	mdio@e3120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe3120 0xee0>;
+		interrupts = <100 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-2.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-2.dtsi
new file mode 100644
index 0000000..d0fd687
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-2.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #2 device tree stub [ controller @ offset 0x400000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@400000 {
+	fman0_rx2: port@8a000 {
+		cell-index = <2>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x8a000 0x1000>;
+	};
+
+	fman0_tx2: port@aa000 {
+		cell-index = <2>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xaa000 0x1000>;
+	};
+
+	ethernet@e4000 {
+		cell-index = <2>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe4000 0x1000>;
+		fsl,port-handles = <&fman0_rx2 &fman0_tx2>;
+		ptimer-handle = <&ptp_timer0>;
+	};
+
+	mdio@e5120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe5120 0xee0>;
+		interrupts = <100 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-3.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-3.dtsi
new file mode 100644
index 0000000..712785e
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-3.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #3 device tree stub [ controller @ offset 0x400000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@400000 {
+	fman0_rx3: port@8b000 {
+		cell-index = <3>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x8b000 0x1000>;
+	};
+
+	fman0_tx3: port@ab000 {
+		cell-index = <3>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xab000 0x1000>;
+	};
+
+	ethernet@e6000 {
+		cell-index = <3>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe6000 0x1000>;
+		fsl,port-handles = <&fman0_rx3 &fman0_tx3>;
+		ptimer-handle = <&ptp_timer0>;
+	};
+
+	mdio@e7120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe7120 0xee0>;
+		interrupts = <100 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-4.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-4.dtsi
new file mode 100644
index 0000000..0ba91f0
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-4.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #4 device tree stub [ controller @ offset 0x400000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@400000 {
+	fman0_rx4: port@8c000 {
+		cell-index = <4>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x8c000 0x1000>;
+	};
+
+	fman0_tx4: port@ac000 {
+		cell-index = <4>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xac000 0x1000>;
+	};
+
+	ethernet@e8000 {
+		cell-index = <4>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe8000 0x1000>;
+		fsl,port-handles = <&fman0_rx4 &fman0_tx4>;
+		ptimer-handle = <&ptp_timer0>;
+	};
+
+	mdio@e9120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe9120 0xee0>;
+		interrupts = <100 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-0.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-0.dtsi
new file mode 100644
index 0000000..c467e01
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-0.dtsi
@@ -0,0 +1,140 @@
+/*
+ * QorIQ FMan device tree stub [ controller @ offset 0x400000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman0: fman@400000 {
+	#address-cells = <1>;
+	#size-cells = <1>;
+	cell-index = <0>;
+	compatible = "fsl,fman", "simple-bus";
+	ranges = <0 0x400000 0x100000>;
+	reg = <0x400000 0x100000>;
+	clock-frequency = <0>;
+	interrupts = <
+		96 2 0 0
+		16 2 1 1>;
+
+	cc {
+		compatible = "fsl,fman-cc";
+	};
+
+	muram@0 {
+		compatible = "fsl,fman-muram";
+		reg = <0x0 0x28000>;
+	};
+
+	bmi@80000 {
+		compatible = "fsl,fman-bmi";
+		reg = <0x80000 0x400>;
+	};
+
+	qmi@80400 {
+		compatible = "fsl,fman-qmi";
+		reg = <0x80400 0x400>;
+	};
+
+	fman0_oh0: port@81000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x81000 0x1000>;
+	};
+
+	fman0_oh1: port@82000 {
+		cell-index = <1>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x82000 0x1000>;
+	};
+
+	fman0_oh2: port@83000 {
+		cell-index = <2>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x83000 0x1000>;
+	};
+
+	fman0_oh3: port@84000 {
+		cell-index = <3>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x84000 0x1000>;
+	};
+
+	fman0_oh4: port@85000 {
+		cell-index = <4>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x85000 0x1000>;
+		status = "disabled";
+	};
+
+	fman0_oh5: port@86000 {
+		cell-index = <5>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x86000 0x1000>;
+		status = "disabled";
+	};
+
+	fman0_oh6: port@87000 {
+		cell-index = <6>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x87000 0x1000>;
+		status = "disabled";
+	};
+
+	policer@c0000 {
+		compatible = "fsl,fman-policer";
+		reg = <0xc0000 0x1000>;
+	};
+
+	keygen@c1000 {
+		compatible = "fsl,fman-keygen";
+		reg = <0xc1000 0x1000>;
+	};
+
+	dma@c2000 {
+		compatible = "fsl,fman-dma";
+		reg = <0xc2000 0x1000>;
+	};
+
+	fpm@c3000 {
+		compatible = "fsl,fman-fpm";
+		reg = <0xc3000 0x1000>;
+	};
+
+	parser@c7000 {
+		compatible = "fsl,fman-parser";
+		reg = <0xc7000 0x1000>;
+	};
+
+	ptp_timer0: rtc@fe000 {
+		compatible = "fsl,fman-rtc";
+		reg = <0xfe000 0x1000>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-1-10g-0.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-10g-0.dtsi
new file mode 100644
index 0000000..2b05dee
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-10g-0.dtsi
@@ -0,0 +1,54 @@
+/*
+ * QorIQ FMan 10g port #0 device tree stub [ controller @ offset 0x500000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@500000 {
+	fman1_10g_rx0: port@90000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-10g-rx";
+		reg = <0x90000 0x1000>;
+	};
+
+	fman1_10g_tx0: port@b0000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-10g-tx";
+		reg = <0xb0000 0x1000>;
+	};
+
+	ethernet@f0000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-10g-mac";
+		reg = <0xf0000 0x1000>;
+		fsl,port-handles = <&fman1_10g_rx0 &fman1_10g_tx0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-0.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-0.dtsi
new file mode 100644
index 0000000..2c46174
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-0.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #0 device tree stub [ controller @ offset 0x500000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@500000 {
+	fman1_rx0: port@88000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x88000 0x1000>;
+	};
+
+	fman1_tx0: port@a8000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xa8000 0x1000>;
+	};
+
+	ethernet@e0000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe0000 0x1000>;
+		fsl,port-handles = <&fman1_rx0 &fman1_tx0>;
+		ptimer-handle = <&ptp_timer1>;
+	};
+
+	mdio@e1120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe1120 0xee0>;
+		interrupts = <101 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-1.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-1.dtsi
new file mode 100644
index 0000000..4bf2932
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-1.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #1 device tree stub [ controller @ offset 0x500000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@500000 {
+	fman1_rx1: port@89000 {
+		cell-index = <1>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x89000 0x1000>;
+	};
+
+	fman1_tx1: port@a9000 {
+		cell-index = <1>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xa9000 0x1000>;
+	};
+
+	ethernet@e2000 {
+		cell-index = <1>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe2000 0x1000>;
+		fsl,port-handles = <&fman1_rx1 &fman1_tx1>;
+		ptimer-handle = <&ptp_timer1>;
+	};
+
+	mdio@e3120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe3120 0xee0>;
+		interrupts = <101 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-2.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-2.dtsi
new file mode 100644
index 0000000..3ae25e4
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-2.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #2 device tree stub [ controller @ offset 0x500000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@500000 {
+	fman1_rx2: port@8a000 {
+		cell-index = <2>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x8a000 0x1000>;
+	};
+
+	fman1_tx2: port@aa000 {
+		cell-index = <2>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xaa000 0x1000>;
+	};
+
+	ethernet@e4000 {
+		cell-index = <2>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe4000 0x1000>;
+		fsl,port-handles = <&fman1_rx2 &fman1_tx2>;
+		ptimer-handle = <&ptp_timer1>;
+	};
+
+	mdio@e5120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe5120 0xee0>;
+		interrupts = <101 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-3.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-3.dtsi
new file mode 100644
index 0000000..516d5b9
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-3.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #3 device tree stub [ controller @ offset 0x500000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@500000 {
+	fman1_rx3: port@8b000 {
+		cell-index = <3>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x8b000 0x1000>;
+	};
+
+	fman1_tx3: port@ab000 {
+		cell-index = <3>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xab000 0x1000>;
+	};
+
+	ethernet@e6000 {
+		cell-index = <3>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe6000 0x1000>;
+		fsl,port-handles = <&fman1_rx3 &fman1_tx3>;
+		ptimer-handle = <&ptp_timer1>;
+	};
+
+	mdio@e7120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe7120 0xee0>;
+		interrupts = <101 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-4.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-4.dtsi
new file mode 100644
index 0000000..647b166
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-4.dtsi
@@ -0,0 +1,63 @@
+/*
+ * QorIQ FMan 1g port #4 device tree stub [ controller @ offset 0x500000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman@500000 {
+	fman1_rx4: port@8c000 {
+		cell-index = <4>;
+		compatible = "fsl,fman-port-1g-rx";
+		reg = <0x8c000 0x1000>;
+	};
+
+	fman1_tx4: port@ac000 {
+		cell-index = <4>;
+		compatible = "fsl,fman-port-1g-tx";
+		reg = <0xac000 0x1000>;
+	};
+
+	ethernet@e8000 {
+		cell-index = <4>;
+		compatible = "fsl,fman-1g-mac";
+		reg = <0xe8000 0x1000>;
+		fsl,port-handles = <&fman1_rx4 &fman1_tx4>;
+		ptimer-handle = <&ptp_timer1>;
+	};
+
+	mdio@e9120 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "fsl,fman-tbi";
+		reg = <0xe9120 0xee0>;
+		interrupts = <101 1 0 0>;
+	};
+};
diff --git a/arch/powerpc/boot/dts/fsl/qoriq-fman-1.dtsi b/arch/powerpc/boot/dts/fsl/qoriq-fman-1.dtsi
new file mode 100644
index 0000000..9e20dfa
--- /dev/null
+++ b/arch/powerpc/boot/dts/fsl/qoriq-fman-1.dtsi
@@ -0,0 +1,140 @@
+/*
+ * QorIQ FMan device tree stub [ controller @ offset 0x500000 ]
+ *
+ * Copyright 2011 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * This software is provided by Freescale Semiconductor "as is" and any
+ * express or implied warranties, including, but not limited to, the implied
+ * warranties of merchantability and fitness for a particular purpose are
+ * disclaimed. In no event shall Freescale Semiconductor be liable for any
+ * direct, indirect, incidental, special, exemplary, or consequential damages
+ * (including, but not limited to, procurement of substitute goods or services;
+ * loss of use, data, or profits; or business interruption) however caused and
+ * on any theory of liability, whether in contract, strict liability, or tort
+ * (including negligence or otherwise) arising in any way out of the use of this
+ * software, even if advised of the possibility of such damage.
+ */
+
+fman1: fman@500000 {
+	#address-cells = <1>;
+	#size-cells = <1>;
+	cell-index = <1>;
+	compatible = "fsl,fman", "simple-bus";
+	ranges = <0 0x500000 0x100000>;
+	reg = <0x500000 0x100000>;
+	clock-frequency = <0>;
+	interrupts = <
+		97 2 0 0
+		16 2 1 0>;
+
+	cc {
+		compatible = "fsl,fman-cc";
+	};
+
+	muram@0 {
+		compatible = "fsl,fman-muram";
+		reg = <0x0 0x28000>;
+	};
+
+	bmi@80000 {
+		compatible = "fsl,fman-bmi";
+		reg = <0x80000 0x400>;
+	};
+
+	qmi@80400 {
+		compatible = "fsl,fman-qmi";
+		reg = <0x80400 0x400>;
+	};
+
+	fman1_oh0: port@81000 {
+		cell-index = <0>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x81000 0x1000>;
+	};
+
+	fman1_oh1: port@82000 {
+		cell-index = <1>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x82000 0x1000>;
+	};
+
+	fman1_oh2: port@83000 {
+		cell-index = <2>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x83000 0x1000>;
+	};
+
+	fman1_oh3: port@84000 {
+		cell-index = <3>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x84000 0x1000>;
+	};
+
+	fman1_oh4: port@85000 {
+		cell-index = <4>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x85000 0x1000>;
+		status = "disabled";
+	};
+
+	fman1_oh5: port@86000 {
+		cell-index = <5>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x86000 0x1000>;
+		status = "disabled";
+	};
+
+	fman1_oh6: port@87000 {
+		cell-index = <6>;
+		compatible = "fsl,fman-port-oh";
+		reg = <0x87000 0x1000>;
+		status = "disabled";
+	};
+
+	policer@c0000 {
+		compatible = "fsl,fman-policer";
+		reg = <0xc0000 0x1000>;
+	};
+
+	keygen@c1000 {
+		compatible = "fsl,fman-keygen";
+		reg = <0xc1000 0x1000>;
+	};
+
+	dma@c2000 {
+		compatible = "fsl,fman-dma";
+		reg = <0xc2000 0x1000>;
+	};
+
+	fpm@c3000 {
+		compatible = "fsl,fman-fpm";
+		reg = <0xc3000 0x1000>;
+	};
+
+	parser@c7000 {
+		compatible = "fsl,fman-parser";
+		reg = <0xc7000 0x1000>;
+	};
+
+	ptp_timer1: rtc@fe000 {
+		compatible = "fsl,fman-rtc";
+		reg = <0xfe000 0x1000>;
+	};
+};
-- 
1.7.3.4
