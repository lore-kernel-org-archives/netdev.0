From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: [v8, 1/7] Documentation: DT: update Freescale DCFG compatible
Date: Fri, 22 Apr 2016 14:27:38 +0800
Message-ID: <1461306464-19521-2-git-send-email-yangbo.lu@nxp.com>
References: <1461306464-19521-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, Zhao Qiang <qiang.zhao-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>, scott.wood-3arQi8VN3Tc@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, Kumar
	Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, leoyang.li-3arQi8VN3Tc@public.gmane.org, xiaobo.xie-3arQi8VN3Tc@public.gmane.org
To: <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1461306464-19521-1-git-send-email-yangbo.lu-3arQi8VN3Tc@public.gmane.org>
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
of 'fsl,ls1021a-dcfg' to include more chips.

Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
---
Changes for v8:
	- Added this patch
---
 Documentation/devicetree/bindings/arm/fsl.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/arm/fsl.txt b/Documentation/devicetree/bindings/arm/fsl.txt
index 752a685..1d5f512 100644
--- a/Documentation/devicetree/bindings/arm/fsl.txt
+++ b/Documentation/devicetree/bindings/arm/fsl.txt
@@ -119,7 +119,7 @@ Freescale DCFG
 configuration and status for the device. Such as setting the secondary
 core start address and release the secondary core from holdoff and startup.
   Required properties:
-  - compatible: should be "fsl,ls1021a-dcfg"
+  - compatible: should be "fsl,<chip>-dcfg"
   - reg : should contain base address and length of DCFG memory-mapped registers
 
 Example:
-- 
2.1.0.27.g96db324
