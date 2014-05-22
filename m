From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/9] Documentation: devicetree: net: refer to fixed-link.txt
Date: Thu, 22 May 2014 09:47:44 -0700
Message-ID: <1400777271-32199-3-git-send-email-f.fainelli@gmail.com>
References: <1400777271-32199-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Li Yang <leoli@freescale.com>,
	Grant Likely <grant.likely@linaro.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Aida Mynzhasova <aida.mynzhasova@skitlab.ru>,
	Richard Cochran <richardcochran@gmail.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	devicetree@vger.kernel.org (open list:OPEN FIRMWARE AND...),
	linux-kernel@vger.kernel.org (open list),
	linuxppc-dev@lists.ozlabs.org (open list:LINUX FOR POWERPC...)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400777271-32199-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the Freescale TSEC PHY, Broadcom GENET & SYSTEMPORT Device Tree
binding documentation to refer to the fixed-link Device Tree binding in
fixed-link.txt.

Reviewed-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
No changes in v2

 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt   | 2 +-
 Documentation/devicetree/bindings/net/broadcom-systemport.txt | 2 +-
 Documentation/devicetree/bindings/net/fsl-tsec-phy.txt        | 5 +----
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
index f2febb94550e..451fef26b4df 100644
--- a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
+++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
@@ -24,7 +24,7 @@ Optional properties:
 - fixed-link: When the GENET interface is connected to a MoCA hardware block or
   when operating in a RGMII to RGMII type of connection, or when the MDIO bus is
   voluntarily disabled, this property should be used to describe the "fixed link".
-  See Documentation/devicetree/bindings/net/fsl-tsec-phy.txt for information on
+  See Documentation/devicetree/bindings/net/fixed-link.txt for information on
   the property specifics
 
 Required child nodes:
diff --git a/Documentation/devicetree/bindings/net/broadcom-systemport.txt b/Documentation/devicetree/bindings/net/broadcom-systemport.txt
index 1b7600e022dd..c183ea90d9bc 100644
--- a/Documentation/devicetree/bindings/net/broadcom-systemport.txt
+++ b/Documentation/devicetree/bindings/net/broadcom-systemport.txt
@@ -8,7 +8,7 @@ Required properties:
 - local-mac-address: Ethernet MAC address (48 bits) of this adapter
 - phy-mode: Should be a string describing the PHY interface to the
   Ethernet switch/PHY, see Documentation/devicetree/bindings/net/ethernet.txt
-- fixed-link: see Documentation/devicetree/bindings/net/fsl-tsec-phy.txt for
+- fixed-link: see Documentation/devicetree/bindings/net/fixed-link.txt for
   the property specific details
 
 Optional properties:
diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
index 737cdef4f903..be6ea8960f20 100644
--- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
+++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
@@ -42,10 +42,7 @@ Properties:
     interrupt.  For TSEC and eTSEC devices, the first interrupt is
     transmit, the second is receive, and the third is error.
   - phy-handle : See ethernet.txt file in the same directory.
-  - fixed-link : <a b c d e> where a is emulated phy id - choose any,
-    but unique to the all specified fixed-links, b is duplex - 0 half,
-    1 full, c is link speed - d#10/d#100/d#1000, d is pause - 0 no
-    pause, 1 pause, e is asym_pause - 0 no asym_pause, 1 asym_pause.
+  - fixed-link : See fixed-link.txt in the same directory.
   - phy-connection-type : See ethernet.txt file in the same directory.
     This property is only really needed if the connection is of type
     "rgmii-id", as all other connection types are detected by hardware.
-- 
1.9.1
