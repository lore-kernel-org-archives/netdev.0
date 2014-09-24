From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v1 2/5] Documentation: dts: Update section header for APM X-Gene
Date: Tue, 23 Sep 2014 20:51:25 -0700
Message-ID: <1411530688-2939-3-git-send-email-isubramanian@apm.com>
References: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
Cc: kchudgar@apm.com, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og113.obsmtp.com ([64.18.0.26]:58992 "HELO
	exprod5og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750711AbaIXDvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 23:51:44 -0400
Received: by mail-pd0-f182.google.com with SMTP id p10so7508354pdj.41
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 20:51:43 -0700 (PDT)
In-Reply-To: <1411530688-2939-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
index ebcad25..60a7857 100644
--- a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -3,7 +3,7 @@ APM X-Gene SoC Ethernet nodes
 Ethernet nodes are defined to describe on-chip ethernet interfaces in
 APM X-Gene SoC.
 
-Required properties:
+Required properties for all the ethernet interfaces:
 - compatible: Should be "apm,xgene-enet"
 - reg: Address and length of the register set for the device. It contains the
   information of registers in the same order as described by reg-names
@@ -15,6 +15,8 @@ Required properties:
 - clocks: Reference to the clock entry.
 - local-mac-address: MAC address assigned to this device
 - phy-connection-type: Interface type between ethernet device and PHY device
+
+Required properties for ethernet interfaces that has external PHY:
 - phy-handle: Reference to a PHY node connected to this device
 
 - mdio: Device tree subnode with the following required properties:
-- 
1.9.1
