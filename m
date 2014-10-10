From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 2/6] Documentation: dts: Update section header for APM X-Gene
Date: Thu,  9 Oct 2014 18:32:03 -0700
Message-ID: <1412904727-23485-3-git-send-email-isubramanian@apm.com>
References: <1412904727-23485-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og101.obsmtp.com ([64.18.0.141]:33764 "HELO
	exprod5og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751195AbaJJBcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 21:32:01 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so703484pdb.35
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 18:32:00 -0700 (PDT)
In-Reply-To: <1412904727-23485-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
index ebcad25..cfcc527 100644
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
+Required properties for ethernet interfaces that have external PHY:
 - phy-handle: Reference to a PHY node connected to this device
 
 - mdio: Device tree subnode with the following required properties:
-- 
1.9.1
