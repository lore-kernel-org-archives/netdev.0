From: Xie Xiaobo <X.Xie@freescale.com>
Subject: [PATCH] powerpc/dts: Add magic-packet properties for etsec
Date: Wed, 22 Feb 2012 15:53:29 +0800
Message-ID: <1329897209-17209-1-git-send-email-X.Xie@freescale.com>
References: <y>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <galak@kernel.crashing.org>, <timur@freescale.com>,
	Xie Xiaobo <X.Xie@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:13102
	"EHLO AM1EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751153Ab2BVH6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 02:58:53 -0500
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The properties indicates that the hardware supports waking up via magic packet.

Signed-off-by: Xie Xiaobo <X.Xie@freescale.com>
---
This patch already submitted to linuxppc-dev mail-list for reviewing.
 arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi |    3 ++-
 arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi |    3 ++-
 arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi |    3 ++-
 arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi |    3 ++-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi
index a1979ae..3b0650a 100644
--- a/arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi
+++ b/arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi
@@ -1,7 +1,7 @@
 /*
  * PQ3 eTSEC device tree stub [ @ offsets 0x24000 ]
  *
- * Copyright 2011 Freescale Semiconductor Inc.
+ * Copyright 2011-2012 Freescale Semiconductor Inc.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -41,6 +41,7 @@ ethernet@24000 {
 	compatible = "gianfar";
 	reg = <0x24000 0x1000>;
 	ranges = <0x0 0x24000 0x1000>;
+	fsl,magic-packet;
 	local-mac-address = [ 00 00 00 00 00 00 ];
 	interrupts = <29 2 0 0 30 2 0 0 34 2 0 0>;
 };
diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi
index 4c4fdde..96693b4 100644
--- a/arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi
+++ b/arch/powerpc/boot/dts/fsl/pq3-etsec1-1.dtsi
@@ -1,7 +1,7 @@
 /*
  * PQ3 eTSEC device tree stub [ @ offsets 0x25000 ]
  *
- * Copyright 2011 Freescale Semiconductor Inc.
+ * Copyright 2011-2012 Freescale Semiconductor Inc.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -41,6 +41,7 @@ ethernet@25000 {
 	compatible = "gianfar";
 	reg = <0x25000 0x1000>;
 	ranges = <0x0 0x25000 0x1000>;
+	fsl,magic-packet;
 	local-mac-address = [ 00 00 00 00 00 00 ];
 	interrupts = <35 2 0 0 36 2 0 0 40 2 0 0>;
 };
diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi
index 4b8ab43..6b3fab1 100644
--- a/arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi
+++ b/arch/powerpc/boot/dts/fsl/pq3-etsec1-2.dtsi
@@ -1,7 +1,7 @@
 /*
  * PQ3 eTSEC device tree stub [ @ offsets 0x26000 ]
  *
- * Copyright 2011 Freescale Semiconductor Inc.
+ * Copyright 2011-2012 Freescale Semiconductor Inc.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -41,6 +41,7 @@ ethernet@26000 {
 	compatible = "gianfar";
 	reg = <0x26000 0x1000>;
 	ranges = <0x0 0x26000 0x1000>;
+	fsl,magic-packet;
 	local-mac-address = [ 00 00 00 00 00 00 ];
 	interrupts = <31 2 0 0 32 2 0 0 33 2 0 0>;
 };
diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi
index 40c9137..0da592d 100644
--- a/arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi
+++ b/arch/powerpc/boot/dts/fsl/pq3-etsec1-3.dtsi
@@ -1,7 +1,7 @@
 /*
  * PQ3 eTSEC device tree stub [ @ offsets 0x27000 ]
  *
- * Copyright 2011 Freescale Semiconductor Inc.
+ * Copyright 2011-2012 Freescale Semiconductor Inc.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -41,6 +41,7 @@ ethernet@27000 {
 	compatible = "gianfar";
 	reg = <0x27000 0x1000>;
 	ranges = <0x0 0x27000 0x1000>;
+	fsl,magic-packet;
 	local-mac-address = [ 00 00 00 00 00 00 ];
 	interrupts = <37 2 0 0 38 2 0 0 39 2 0 0>;
 };
-- 
1.7.5.1
