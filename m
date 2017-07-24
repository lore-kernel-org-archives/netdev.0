From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 11/18] Documentation/bindings: net: marvell-pp2: add the system controller
Date: Mon, 24 Jul 2017 15:48:41 +0200
Message-ID: <20170724134848.19330-12-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47372 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755895AbdGXNuK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:10 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch documents the new marvell,system-controller property used by
the Marvell ppv2 network driver.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 Documentation/devicetree/bindings/net/marvell-pp2.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index 6b4956beff8c..18ec66e51b0a 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -41,6 +41,7 @@ Optional properties (port):
 - marvell,loopback: port is loopback mode
 - phy: a phandle to a phy node defining the PHY address (as the reg
   property, a single integer).
+- marvell,system-controller: a phandle to the system controller.
 
 Example for marvell,armada-375-pp2:
 
-- 
2.13.3
