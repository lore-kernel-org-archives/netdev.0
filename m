From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v2 2/6] Documentation: dts: Update section header for APM X-Gene
Date: Thu,  2 Oct 2014 17:02:44 -0700
Message-ID: <1412294568-26747-3-git-send-email-isubramanian@apm.com>
References: <1412294568-26747-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	kchudgar-qTEPVZfXA3Y@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1412294568-26747-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
