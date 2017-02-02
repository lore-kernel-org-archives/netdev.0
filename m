From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH] dt-bindings: net: remove reference to fixed link support
Date: Thu,  2 Feb 2017 17:47:44 +0100
Message-ID: <1486054064-31093-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Russell King <linux@arm.linux.org.uk>,
        Marcin Wojtas <mw@semihalf.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:57141 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751377AbdBBQrz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:47:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Contrary to what the Device Tree binding indicates, the binding for the
PPv2 network device currently doesn't provide any fixed link
functionality. This commit adjusts the Device Tree binding documentation
accordingly.

Reported-by: Russell King - ARM Linux <linux@armlinux.org.uk>
Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 Documentation/devicetree/bindings/net/marvell-pp2.txt | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index aa4f423..4754364 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -27,9 +27,7 @@ Optional properties (port):
 
 - marvell,loopback: port is loopback mode
 - phy: a phandle to a phy node defining the PHY address (as the reg
-  property, a single integer). Note: if this property isn't present,
-  then fixed link is assumed, and the 'fixed-link' property is
-  mandatory.
+  property, a single integer).
 
 Example:
 
-- 
2.7.4
