From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 1/3][RESEND] doc: dt: net: Add fsl,wake-on-filer for eTSEC
Date: Mon, 5 Oct 2015 17:19:57 +0300
Message-ID: <1444054799-17876-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Zhao Chenhui <chenhui.zhao@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0121.outbound.protection.outlook.com ([65.55.169.121]:6034
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751267AbbJEOZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 10:25:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the "fsl,wake-on-filer" property for eTSEC nodes to
indicate that the system has the power management
infrastructure needed to be able to wake up the system
via FGPI (filer, aka. h/w rx parser) interrupt.

Cc: Li Yang <leoli@freescale.com>
Cc: Zhao Chenhui <chenhui.zhao@freescale.com>

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
Patch initially sent to the ppc-devel list,
resend it to the netdev list:
http://patchwork.ozlabs.org/patch/524902/

 Documentation/devicetree/bindings/net/fsl-tsec-phy.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
index 1e97532..db74f0d 100644
--- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
+++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
@@ -57,6 +57,10 @@ Properties:
     "rgmii-id", as all other connection types are detected by hardware.
   - fsl,magic-packet : If present, indicates that the hardware supports
     waking up via magic packet.
+  - fsl,wake-on-filer : If present, indicates that the hardware supports
+    waking up by Filer General Purpose Interrupt (FGPI) asserted on the
+    Rx int line.  This is an advanced power management capability allowing
+    certain packet types (user) defined by filer rules to wake up the system.
   - bd-stash : If present, indicates that the hardware supports stashing
     buffer descriptors in the L2.
   - rx-stash-len : Denotes the number of bytes of a received buffer to stash
-- 
1.7.11.7
