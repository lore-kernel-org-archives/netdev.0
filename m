From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: [v12, 1/8] dt: bindings: update Freescale DCFG compatible
Date: Wed, 21 Sep 2016 14:57:13 +0800
Message-ID: <1474441040-11946-2-git-send-email-yangbo.lu@nxp.com>
References: <1474441040-11946-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	Minghuan Lian <minghuan.lian-3arQi8VN3Tc@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Bhupesh
	Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Scott Wood
	<oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1474441040-11946-1-git-send-email-yangbo.lu-3arQi8VN3Tc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Update Freescale DCFG compatible with 'fsl,<chip>-dcfg' instead
of 'fsl,ls1021a-dcfg' to include more chips such as ls1021a,
ls1043a, and ls2080a.

Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
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
