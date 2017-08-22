From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 08/10] Documentation/bindings: net: marvell-pp2: add the system controller
Date: Tue, 22 Aug 2017 19:08:28 +0200
Message-ID: <20170822170830.32413-9-antoine.tenart@free-electrons.com>
References: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38586 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751674AbdHVRIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:08:51 -0400
In-Reply-To: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch documents the new marvell,system-controller property used by
the Marvell ppv2 network driver.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Tested-by: Marcin Wojtas <mw@semihalf.com>
---
 Documentation/devicetree/bindings/net/marvell-pp2.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index 8918ad3ccf14..49484db81583 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -45,6 +45,7 @@ Optional properties (port):
                    be the name associated to the interrupts listed. Valid
                    names are: "tx-cpu0", "tx-cpu1", "tx-cpu2", "tx-cpu3",
 		   "rx-shared".
+- marvell,system-controller: a phandle to the system controller.
 
 Example for marvell,armada-375-pp2:
 
-- 
2.13.5
