From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v2 2/2] Documentation: dts: xgene: Add TX/RX delay field
Date: Mon, 26 Oct 2015 15:25:16 -0700
Message-ID: <1445898316-21372-3-git-send-email-isubramanian@apm.com>
References: <1445898316-21372-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, f.fainelli@gmail.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35362 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbbJZWYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 18:24:42 -0400
Received: by pasz6 with SMTP id z6so200245261pas.2
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 15:24:41 -0700 (PDT)
In-Reply-To: <1445898316-21372-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
index f55aa28..078060a 100644
--- a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -37,6 +37,14 @@ Required properties for ethernet interfaces that have external PHY:
 
 Optional properties:
 - status: Should be "ok" or "disabled" for enabled/disabled. Default is "ok".
+- tx-delay: Delay value for RGMII bridge TX clock.
+	    Valid values are between 0 to 7, that maps to
+	    417, 717, 1020, 1321, 1611, 1913, 2215, 2514 ps
+	    Default value is 4, which corresponds to 1611 ps
+- rx-delay: Delay value for RGMII bridge RX clock.
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
