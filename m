From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH v4 1/3] net: mvneta: introduce compatible string "marvell,armada-xp-neta"
Date: Tue, 30 Jun 2015 16:20:20 +0200
Message-ID: <1435674022-13295-2-git-send-email-simon.guinot@sequanux.org>
References: <1435674022-13295-1-git-send-email-simon.guinot@sequanux.org>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	<stable@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:57968 "EHLO vm1.sequanux.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753539AbbF3OU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 10:20:26 -0400
In-Reply-To: <1435674022-13295-1-git-send-email-simon.guinot@sequanux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvneta driver supports the Ethernet IP found in the Armada 370, XP,
380 and 385 SoCs. Since at least one more hardware feature is available
for the Armada XP SoCs then a way to identify them is needed.

This patch introduces a new compatible string "marvell,armada-xp-neta".

Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network unit")
Cc: <stable@vger.kernel.org> # v3.8+
Acked-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt | 2 +-
 drivers/net/ethernet/marvell/mvneta.c                             | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
index 750d577e8083..f5a8ca29aff0 100644
--- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -1,7 +1,7 @@
 * Marvell Armada 370 / Armada XP Ethernet Controller (NETA)
 
 Required properties:
-- compatible: should be "marvell,armada-370-neta".
+- compatible: "marvell,armada-370-neta" or "marvell,armada-xp-neta".
 - reg: address and length of the register set for the device.
 - interrupts: interrupt for the device
 - phy: See ethernet.txt file in the same directory.
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ce5f7f9cff06..aceb977b104d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3179,6 +3179,7 @@ static int mvneta_remove(struct platform_device *pdev)
 
 static const struct of_device_id mvneta_match[] = {
 	{ .compatible = "marvell,armada-370-neta" },
+	{ .compatible = "marvell,armada-xp-neta" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, mvneta_match);
-- 
2.1.4
