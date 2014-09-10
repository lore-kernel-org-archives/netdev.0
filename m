From: <yes-KgLukfWpBlCctlrPMvKcciBecyulp+rMXqFh9Ls21Oc@public.gmane.org>
Subject: [Patch v3 net-next 11/12] ARM: Documentation: Update fec dts binding doc
Date: Thu, 11 Sep 2014 02:30:12 +0800
Message-ID: <21196.2722278715$1410375286@news.gmane.org>
References: <1410373813-5731-1-git-send-email-yes>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410373813-5731-1-git-send-email-yes>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

    This patch update fec devicetree binding doc that add Optional
    properties "fsl,num-tx-queues" and "fsl,num-rx-queues".

Signed-off-by: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Signed-off-by: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
