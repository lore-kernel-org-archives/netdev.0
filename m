From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v3 4/4] dtb: xgene: Add irqs to support multi queue
Date: Wed, 17 Feb 2016 15:00:42 -0800
Message-ID: <1455750042-1521-5-git-send-email-isubramanian@apm.com>
References: <1455750042-1521-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, toanle@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>,
	Khuong Dinh <kdinh@apm.com>, Tanmay Inamdar <tinamdar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33560 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424436AbcBQXBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 18:01:50 -0500
Received: by mail-pa0-f52.google.com with SMTP id fl4so18987527pad.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 15:01:49 -0800 (PST)
In-Reply-To: <1455750042-1521-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Khuong Dinh <kdinh@apm.com>
Signed-off-by: Tanmay Inamdar <tinamdar@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi | 8 +++++++-
 arch/arm64/boot/dts/apm/apm-storm.dtsi     | 8 +++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
index 5d87a3d..278f106 100644
--- a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
@@ -621,7 +621,13 @@
 			      <0x0 0x1f600000 0x0 0Xd100>,
 			      <0x0 0x20000000 0x0 0X220000>;
 			interrupts = <0 108 4>,
-				     <0 109 4>;
+				     <0 109 4>,
+				     <0 110 4>,
+				     <0 111 4>,
+				     <0 112 4>,
+				     <0 113 4>,
+				     <0 114 4>,
+				     <0 115 4>;
 			port-id = <1>;
 			dma-coherent;
 			clocks = <&xge1clk 0>;
diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index fe30f76..cafb2c2 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -958,7 +958,13 @@
 			      <0x0 0x18000000 0x0 0X200>;
 			reg-names = "enet_csr", "ring_csr", "ring_cmd";
 			interrupts = <0x0 0x60 0x4>,
-				     <0x0 0x61 0x4>;
+				     <0x0 0x61 0x4>,
+				     <0x0 0x62 0x4>,
+				     <0x0 0x63 0x4>,
+				     <0x0 0x64 0x4>,
+				     <0x0 0x65 0x4>,
+				     <0x0 0x66 0x4>,
+				     <0x0 0x67 0x4>;
 			dma-coherent;
 			clocks = <&xge0clk 0>;
 			/* mac address will be overwritten by the bootloader */
-- 
1.9.1
