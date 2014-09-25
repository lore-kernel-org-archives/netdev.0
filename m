From: Luwei Zhou <b45643@freescale.com>
Subject: [PATCH v1 4/4] ARM: Documentation: Update fec dts binding doc
Date: Thu, 25 Sep 2014 16:10:21 +0800
Message-ID: <1411632621-17429-5-git-send-email-b45643@freescale.com>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<b38611@freescale.com>, <b20596@freescale.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0144.outbound.protection.outlook.com ([157.56.111.144]:61760
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751020AbaIYJYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 05:24:15 -0400
In-Reply-To: <1411632621-17429-1-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch update fec devicetree binding doc that add Optional properties
"pps-channel".

Signed-off-by: Luwei Zhou <b45643@freescale.com>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index 0c8775c..14a4fbb 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -22,6 +22,8 @@ Optional properties:
 - fsl,num-rx-queues : The property is valid for enet-avb IP, which supports
   hw multi queues. Should specify the rx queue number, otherwise set rx queue
   number to 1.
+- pps-channel: The FEC ptp support 4 channel timer. Specify the channel number
+  to output PPS signal.
 
 Optional subnodes:
 - mdio : specifies the mdio bus in the FEC, used as a container for phy nodes
-- 
1.9.1
