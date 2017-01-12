From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: =?UTF-8?q?=5B=C2PATCH=20net-next=5D=20ARM=3A=20dts=3A=20vf610-zii-dev=3A=20add=20EEPROM=20entry=20to=20Rev=20B?=
Date: Thu, 12 Jan 2017 17:56:19 -0500
Message-ID: <20170112225619.31677-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51298 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbdALW5R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 17:57:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ZII Dev Rev B board has EEPROMs hanging the 88E6352 Ethernet switch
chips. Add an "eeprom-length" property to allow access from ethtool.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 958b4c42d320..b60d3d03f58c 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -98,6 +98,7 @@
 				interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
 				interrupt-controller;
 				#interrupt-cells = <2>;
+				eeprom-length = <512>;
 
 				ports {
 					#address-cells = <1>;
@@ -181,6 +182,7 @@
 				interrupts = <26 IRQ_TYPE_LEVEL_LOW>;
 				interrupt-controller;
 				#interrupt-cells = <2>;
+				eeprom-length = <512>;
 
 				ports {
 					#address-cells = <1>;
-- 
2.11.0
