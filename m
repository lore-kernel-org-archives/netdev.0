From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 3/3] dtb: xgene: Add channel property
Date: Fri, 29 Apr 2016 11:10:15 -0700
Message-ID: <1461953415-9741-4-git-send-email-isubramanian@apm.com>
References: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36385 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbcD2SJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 14:09:56 -0400
Received: by mail-pa0-f54.google.com with SMTP id bt5so48189790pac.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 11:09:55 -0700 (PDT)
In-Reply-To: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added 'channel' property, describing ethernet to CPU channel number.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi | 1 +
 arch/arm64/boot/dts/apm/apm-storm.dtsi     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
index a055a5d..ba04877 100644
--- a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
@@ -653,6 +653,7 @@
 				     <0 113 4>,
 				     <0 114 4>,
 				     <0 115 4>;
+			channel = <12>;
 			port-id = <1>;
 			dma-coherent;
 			clocks = <&xge1clk 0>;
diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index ae4a173..5147d76 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -993,6 +993,7 @@
 				     <0x0 0x65 0x4>,
 				     <0x0 0x66 0x4>,
 				     <0x0 0x67 0x4>;
+			channel = <0>;
 			dma-coherent;
 			clocks = <&xge0clk 0>;
 			/* mac address will be overwritten by the bootloader */
-- 
1.9.1
