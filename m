From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH v3] ARM: dts: tango4: Request RGMII RX and TX clock delays
Date: Fri, 28 Jul 2017 15:27:49 +0200
Message-ID: <d669e207-ae47-4c9e-67c5-75424fde501f@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>, Mason <slash.tmp@free.fr>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: arm-soc <arm@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:34243 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751668AbdG1N1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 09:27:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX and TX clock delays are required. Request them explicitly.

Fixes: cad008b8a77e6 ("ARM: dts: tango4: Initial device trees")
Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
Arnd, Kevin, Olof, can one of you take this patch through arm-soc?
Greg will apply it to all stable branches, right?
---
 arch/arm/boot/dts/tango4-vantage-1172.dts | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/tango4-vantage-1172.dts b/arch/arm/boot/dts/tango4-vantage-1172.dts
index 86d8df98802f..13bcc460bcb2 100644
--- a/arch/arm/boot/dts/tango4-vantage-1172.dts
+++ b/arch/arm/boot/dts/tango4-vantage-1172.dts
@@ -22,7 +22,7 @@
 };
 
 &eth0 {
-	phy-connection-type = "rgmii";
+	phy-connection-type = "rgmii-id";
 	phy-handle = <&eth0_phy>;
 	#address-cells = <1>;
 	#size-cells = <0>;
-- 
2.11.0
