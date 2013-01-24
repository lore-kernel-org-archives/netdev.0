From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 2/2 net-next] doc: dt: fsl: fec: add napi optional properties
Date: Thu, 24 Jan 2013 15:06:59 +0800
Message-ID: <1359011219-8343-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe003.messaging.microsoft.com ([213.199.154.141]:33044
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752294Ab3AXHpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 02:45:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index d536392..4a94090 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -15,6 +15,8 @@ Optional properties:
   only if property "phy-reset-gpios" is available.  Missing the property
   will have the duration be 1 millisecond.  Numbers greater than 1000 are
   invalid and 1 millisecond will be used instead.
+- disable_napi : disable napi support
+- napi_weight : napi weight number, default value is 64
 
 Example:
 
-- 
1.7.1
