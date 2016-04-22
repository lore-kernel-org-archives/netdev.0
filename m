From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: [v8, 6/7] MAINTAINERS: add entry for Freescale SoC specific driver
Date: Fri, 22 Apr 2016 14:27:43 +0800
Message-ID: <1461306464-19521-7-git-send-email-yangbo.lu@nxp.com>
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

Add maintainer entry for Freescale SoC specific driver including
the QE library and the GUTS driver. Also add entry for GUTS driver
and add maintainer for QE library.

Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
---
Changes for v8:
	- Added this patch
---
 MAINTAINERS | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1d5b4be..d20aeb6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4622,13 +4622,27 @@ F:	drivers/net/ethernet/freescale/fec_ptp.c
 F:	drivers/net/ethernet/freescale/fec.h
 F:	Documentation/devicetree/bindings/net/fsl-fec.txt
 
+FREESCALE SOC SPECIFIC DRIVER
+M:	Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
+L:	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
+S:	Maintained
+F:	drivers/soc/fsl/
+F:	include/linux/fsl/
+
 FREESCALE QUICC ENGINE LIBRARY
+M:	Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>
 L:	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
-S:	Orphan
+S:	Maintained
 F:	drivers/soc/fsl/qe/
 F:	include/soc/fsl/*qe*.h
 F:	include/soc/fsl/*ucc*.h
 
+FREESCALE GUTS DRIVER
+M:	Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
+L:	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
+S:	Maintained
+F:	drivers/soc/fsl/guts.c
+
 FREESCALE USB PERIPHERAL DRIVERS
 M:	Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
 L:	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
-- 
2.1.0.27.g96db324
