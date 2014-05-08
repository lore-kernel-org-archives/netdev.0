From: Johan Hovold <jhovold@gmail.com>
Subject: [PATCH RESEND 1/5] net: mdio-gpio: fix device-tree binding documentation
Date: Thu,  8 May 2014 10:09:20 +0200
Message-ID: <1399536564-7626-2-git-send-email-jhovold@gmail.com>
References: <1399534639-4947-1-git-send-email-jhovold@gmail.com>
 <1399536564-7626-1-git-send-email-jhovold@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Johan Hovold <jhovold@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:50118 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaEHIJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 04:09:58 -0400
In-Reply-To: <1399536564-7626-1-git-send-email-jhovold@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix aliases syntax in device-tree binding example to avoid
copy-paste errors (the alias would be dropped silently).

Signed-off-by: Johan Hovold <jhovold@gmail.com>
---
 Documentation/devicetree/bindings/net/mdio-gpio.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/mdio-gpio.txt b/Documentation/devicetree/bindings/net/mdio-gpio.txt
index c79bab025369..8dbcf8295c6c 100644
--- a/Documentation/devicetree/bindings/net/mdio-gpio.txt
+++ b/Documentation/devicetree/bindings/net/mdio-gpio.txt
@@ -14,7 +14,7 @@ node.
 Example:
 
 aliases {
-	mdio-gpio0 = <&mdio0>;
+	mdio-gpio0 = &mdio0;
 };
 
 mdio0: mdio {
-- 
1.8.3.2
