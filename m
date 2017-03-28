From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] ARM: dts: vf610-zii-dev-rev-b: change switch2 label
Date: Tue, 28 Mar 2017 15:11:26 -0400
Message-ID: <20170328191126.18773-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51588 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755290AbdC1TNQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 15:13:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the switch2@0 label of the switch2 node to switch@0 to respect
the general unit@address DTS rule, and be consistent with the other
switch nodes of the DTS file.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 7940408838df..5a93f2d875b1 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -239,7 +239,7 @@
 			#size-cells = <0>;
 			reg = <4>;
 
-			switch2: switch2@0 {
+			switch2: switch@0 {
 				compatible = "marvell,mv88e6085";
 				#address-cells = <1>;
 				#size-cells = <0>;
-- 
2.12.1
