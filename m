From: Frank Li <Frank.Li@freescale.com>
Subject: [Patch v2 net-next 11/12] ARM: Documentation: Update fec dts binding doc
Date: Wed, 10 Sep 2014 04:15:42 +0800
Message-ID: <1410293743-27874-12-git-send-email-Frank.Li@freescale.com>
References: <1410293743-27874-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0117.outbound.protection.outlook.com ([157.56.110.117]:42976
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752698AbaIIUj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 16:39:28 -0400
In-Reply-To: <1410293743-27874-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    This patch update fec devicetree binding doc that add Optional
    properties "fsl,num-tx-queues" and "fsl,num-rx-queues".

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index 8a2c7b5..0c8775c 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -16,6 +16,12 @@ Optional properties:
 - phy-handle : phandle to the PHY device connected to this device.
 - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
   Use instead of phy-handle.
+- fsl,num-tx-queues : The property is valid for enet-avb IP, which supports
+  hw multi queues. Should specify the tx queue number, otherwise set tx queue
+  number to 1.
+- fsl,num-rx-queues : The property is valid for enet-avb IP, which supports
+  hw multi queues. Should specify the rx queue number, otherwise set rx queue
+  number to 1.
 
 Optional subnodes:
 - mdio : specifies the mdio bus in the FEC, used as a container for phy nodes
-- 
1.9.1
