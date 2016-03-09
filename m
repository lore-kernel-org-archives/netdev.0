From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v6, 3/5] dt: move guts devicetree doc out of powerpc directory
Date: Wed, 9 Mar 2016 18:08:49 +0800
Message-ID: <1457518131-11339-4-git-send-email-yangbo.lu@nxp.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>, <scott.wood@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	<ulf.hansson@linaro.org>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	"Zhao Qiang" <qiang.zhao@freescale.com>,
	Kumar Gala <galak@codeaurora.org>,
	"Santosh Shilimkar" <ssantosh@kernel.org>, <leoyang.li@nxp.com>,
	<xiaobo.xie@nxp.com>, Yangbo Lu <yangbo.lu@nxp.com>
To: <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-clk@vger.kernel.org>, <linux-i2c@vger.kernel.org>,
	<iommu@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<linux-mmc@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0085.outbound.protection.outlook.com ([65.55.169.85]:18512
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752395AbcCIKSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 05:18:38 -0500
In-Reply-To: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move guts devicetree doc to Documentation/devicetree/bindings/soc/fsl/
since it's used by not only PowerPC but also ARM. And add a specification
for 'little-endian' property.

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
---
Changes for v2:
	- None
Changes for v3:
	- None
Changes for v4:
	- Added this patch
Changes for v5:
	- Modified the description for little-endian property
Changes for v6:
	- None
---
 Documentation/devicetree/bindings/{powerpc => soc}/fsl/guts.txt | 3 +++
 1 file changed, 3 insertions(+)
 rename Documentation/devicetree/bindings/{powerpc => soc}/fsl/guts.txt (91%)

diff --git a/Documentation/devicetree/bindings/powerpc/fsl/guts.txt b/Documentation/devicetree/bindings/soc/fsl/guts.txt
similarity index 91%
rename from Documentation/devicetree/bindings/powerpc/fsl/guts.txt
rename to Documentation/devicetree/bindings/soc/fsl/guts.txt
index b71b203..07adca9 100644
--- a/Documentation/devicetree/bindings/powerpc/fsl/guts.txt
+++ b/Documentation/devicetree/bindings/soc/fsl/guts.txt
@@ -25,6 +25,9 @@ Recommended properties:
  - fsl,liodn-bits : Indicates the number of defined bits in the LIODN
    registers, for those SOCs that have a PAMU device.
 
+ - little-endian : Indicates that the global utilities block is little
+   endian. The default is big endian.
+
 Examples:
 	global-utilities@e0000 {	/* global utilities block */
 		compatible = "fsl,mpc8548-guts";
-- 
2.1.0.27.g96db324
