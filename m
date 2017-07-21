From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH v2 4/4] ARM: dts: tango4: Add RGMII RX and TX clock delays
Date: Fri, 21 Jul 2017 13:29:49 +0200
Message-ID: <5ee7b36f-9c46-d36e-08c6-2aa52a77f559@sigmadesigns.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:31653 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752433AbdGULxY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 07:53:24 -0400
In-Reply-To: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX and TX clock delays are required.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
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
