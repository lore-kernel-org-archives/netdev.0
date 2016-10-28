From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v14, 1/8] dt: bindings: update Freescale DCFG compatible
Date: Fri, 28 Oct 2016 13:45:14 +0800
Message-ID: <1477633521-7391-2-git-send-email-yangbo.lu@nxp.com>
References: <1477633521-7391-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <devicetree@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>, <linux-clk@vger.kernel.org>,
        <linux-i2c@vger.kernel.org>, <iommu@lists.linux-foundation.org>,
        <netdev@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>,
        Russell King <linux@arm.linux.org.uk>,
        Jochen Friedrich <jochen@scram.de>,
        Joerg Roedel <joro@8bytes.org>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Bhupesh Sharma <bhupesh.sharma@freescale.com>,
        Qiang Zhao <qiang.zhao@nxp.com>,
        Kumar Gala <galak@codeaurora.org>,
        Santosh Shilimkar <ssantosh@kernel.org>,
        Leo Li <leoyang.li@nxp.com>, Xiaobo Xie <xiaobo.xie@nxp.com>,
        Minghuan Lian
To: <linux-mmc@vger.kernel.org>, <ulf.hansson@linaro.org>,
        Scott Wood <oss@buserror.net>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-i2c-owner@vger.kernel.org>
In-Reply-To: <1477633521-7391-1-git-send-email-yangbo.lu@nxp.com>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update Freescale DCFG compatible with 'fsl,<chip>-dcfg' instead
of 'fsl,ls1021a-dcfg' to include more chips such as ls1021a,
ls1043a, and ls2080a.

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
Acked-by: Rob Herring <robh@kernel.org>
Signed-off-by: Scott Wood <oss@buserror.net>
---
Changes for v8:
	- Added this patch
Changes for v9:
	- Added a list for the possible compatibles
Changes for v10:
	- None
Changes for v11:
	- Added 'Acked-by: Rob Herring'
	- Updated commit message by Scott
Changes for v12:
	- None
Changes for v13:
	- None
Changes for v14:
	- None
---
 Documentation/devicetree/bindings/arm/fsl.txt | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/arm/fsl.txt b/Documentation/devicetree/bindings/arm/fsl.txt
index dbbc095..713c1ae 100644
--- a/Documentation/devicetree/bindings/arm/fsl.txt
+++ b/Documentation/devicetree/bindings/arm/fsl.txt
@@ -119,7 +119,11 @@ Freescale DCFG
 configuration and status for the device. Such as setting the secondary
 core start address and release the secondary core from holdoff and startup.
   Required properties:
-  - compatible: should be "fsl,ls1021a-dcfg"
+  - compatible: should be "fsl,<chip>-dcfg"
+    Possible compatibles:
+	"fsl,ls1021a-dcfg"
+	"fsl,ls1043a-dcfg"
+	"fsl,ls2080a-dcfg"
   - reg : should contain base address and length of DCFG memory-mapped registers
 
 Example:
-- 
2.1.0.27.g96db324
