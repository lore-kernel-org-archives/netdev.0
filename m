From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 7/7] Documentation: update Ethernet PHY devices binding with 'max-speed'
Date: Thu, 5 Dec 2013 14:52:16 -0800
Message-ID: <1386283936-26104-8-git-send-email-florian@openwrt.org>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <abrodkin@synopsys.com>,
	<rob.herring@calxeda.com>, <mark.rutland@arm.com>,
	<sebastian.hesselbarth@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:47732 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798Ab3LEXB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:01:56 -0500
In-Reply-To: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>

The 'max-speed' property is optional but defined in the ePAPR
specification and now supported by the Linux Device Tree parsing
infrastructure.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/phy.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index 7cd18fb..f648094 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -22,6 +22,7 @@ Optional Properties:
   specifications. If neither of these are specified, the default is to
   assume clause 22. The compatible list may also contain other
   elements.
+- max-speed: Maximum PHY supported speed (10, 100, 1000...)
 
 Example:
 
-- 
1.8.3.2
