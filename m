From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 3/3] Documentation/bindings: net: marvell-pp2: add the link interrupt
Date: Thu, 31 Aug 2017 09:12:56 +0200
Message-ID: <20170831071256.18416-4-antoine.tenart@free-electrons.com>
References: <20170831071256.18416-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:39160 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbdHaHPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 03:15:03 -0400
In-Reply-To: <20170831071256.18416-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A link interrupt can be described. Document this valid interrupt name.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Tested-by: Marcin Wojtas <mw@semihalf.com>
---
 Documentation/devicetree/bindings/net/marvell-pp2.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index 49484db81583..c78f3187dfea 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -44,7 +44,7 @@ Optional properties (port):
 - interrupt-names: if more than a single interrupt for rx is given, must
                    be the name associated to the interrupts listed. Valid
                    names are: "tx-cpu0", "tx-cpu1", "tx-cpu2", "tx-cpu3",
-		   "rx-shared".
+		   "rx-shared", "link".
 - marvell,system-controller: a phandle to the system controller.
 
 Example for marvell,armada-375-pp2:
-- 
2.13.5
