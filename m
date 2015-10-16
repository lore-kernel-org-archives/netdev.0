From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 2/2] Documentation: dts: xgene: Add TX/RX delay field
Date: Fri, 16 Oct 2015 13:35:52 -0700
Message-ID: <1445027752-16982-3-git-send-email-isubramanian@apm.com>
References: <1445027752-16982-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34041 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932370AbbJPUfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 16:35:33 -0400
Received: by pacez2 with SMTP id ez2so13809942pac.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 13:35:32 -0700 (PDT)
In-Reply-To: <1445027752-16982-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
index f55aa28..5b17c13 100644
--- a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -37,6 +37,14 @@ Required properties for ethernet interfaces that have external PHY:
 
 Optional properties:
 - status: Should be "ok" or "disabled" for enabled/disabled. Default is "ok".
+- tx-delay: Delay value for RGMII TXD timming.
+	    Valid values are between 0 to 7, that maps to
+	    417, 717, 1020, 1321, 1611, 1913, 2215, 2514 ps
+	    Default value is 4, which corresponds to 1611 ps
+- rx-delay: Delay value for RGMII RXD timming in ps.
+	    Valid values are between 0 to 7, that maps to
+	    273, 589, 899, 1222, 1480, 1806, 2147, 2464 ps
+	    Default value is 2, which corresponds to 899 ps
 
 Example:
 	menetclk: menetclk {
@@ -72,5 +80,7 @@ Example:
 
 /* Board-specific peripheral configurations */
 &menet {
+	tx-delay = <4>;
+	rx-delay = <2>;
         status = "ok";
 };
-- 
1.9.1
