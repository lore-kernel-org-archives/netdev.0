From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v2 12/12] dtb: xgene: Fix backward compatibility
Date: Fri, 12 Aug 2016 22:05:48 -0700
Message-ID: <1471064748-28033-13-git-send-email-isubramanian@apm.com>
References: <1471064748-28033-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33213 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbcHMFFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 01:05:05 -0400
Received: by mail-pf0-f170.google.com with SMTP id y134so2075012pfg.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 22:05:04 -0700 (PDT)
In-Reply-To: <1471064748-28033-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the backward compatibility when used with older kernel.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 arch/arm64/boot/dts/apm/apm-storm.dtsi | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index f1c2c71..d5c3435 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -923,7 +923,7 @@
 			/* mac address will be overwritten by the bootloader */
 			local-mac-address = [00 00 00 00 00 00];
 			phy-connection-type = "rgmii";
-			phy-handle = <&menet0phy>,<&menetphy>;
+			phy-handle = <&menetphy>,<&menet0phy>;
 			mdio {
 				compatible = "apm,xgene-mdio";
 				#address-cells = <1>;
-- 
1.9.1
