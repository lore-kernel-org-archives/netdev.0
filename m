From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v1 2/3] dtb: xgene: Add interrupt for Tx completion
Date: Wed, 25 Mar 2015 12:19:11 -0700
Message-ID: <1427311152-30333-3-git-send-email-isubramanian@apm.com>
References: <1427311152-30333-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:46620 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752860AbbCYTOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:14:25 -0400
Received: by pagj7 with SMTP id j7so38228726pag.2
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:14:24 -0700 (PDT)
In-Reply-To: <1427311152-30333-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 arch/arm64/boot/dts/apm/apm-storm.dtsi | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index c1eb691..e74f6e0 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -638,7 +638,8 @@
 			      <0x0 0x1f200000 0x0 0Xc300>,
 			      <0x0 0x1B000000 0x0 0X200>;
 			reg-names = "enet_csr", "ring_csr", "ring_cmd";
-			interrupts = <0x0 0xA0 0x4>;
+			interrupts = <0x0 0xA0 0x4>,
+				     <0x0 0xA1 0x4>;
 			dma-coherent;
 			clocks = <&sge0clk 0>;
 			local-mac-address = [00 00 00 00 00 00];
@@ -652,7 +653,8 @@
 			      <0x0 0x1f200000 0x0 0Xc300>,
 			      <0x0 0x1B000000 0x0 0X8000>;
 			reg-names = "enet_csr", "ring_csr", "ring_cmd";
-			interrupts = <0x0 0xAC 0x4>;
+			interrupts = <0x0 0xAC 0x4>,
+				     <0x0 0xAD 0x4>;
 			port-id = <1>;
 			dma-coherent;
 			clocks = <&sge1clk 0>;
@@ -667,7 +669,8 @@
 			      <0x0 0x1f600000 0x0 0Xc300>,
 			      <0x0 0x18000000 0x0 0X200>;
 			reg-names = "enet_csr", "ring_csr", "ring_cmd";
-			interrupts = <0x0 0x60 0x4>;
+			interrupts = <0x0 0x60 0x4>,
+				     <0x0 0x61 0x4>;
 			dma-coherent;
 			clocks = <&xge0clk 0>;
 			/* mac address will be overwritten by the bootloader */
-- 
1.9.1
