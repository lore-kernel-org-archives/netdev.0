From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: [v16, 1/7] ARM64: dts: ls2080a: add device configuration node
Date: Wed, 9 Nov 2016 11:14:06 +0800
Message-ID: <1478661252-42439-2-git-send-email-yangbo.lu@nxp.com>
References: <1478661252-42439-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	Minghuan Lian <minghuan.lian-3arQi8VN3Tc@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Scott Wood
	<oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1478661252-42439-1-git-send-email-yangbo.lu-3arQi8VN3Tc@public.gmane.org>
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

Add the dts node for device configuration unit that provides
general purpose configuration and status for the device.

Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Acked-by: Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
Changes for v5:
	- Added this patch
Changes for v6:
	- None
Changes for v7:
	- None
Changes for v8:
	- Added 'Acked-by: Scott Wood'
Changes for v9:
	- None
Changes for v10:
	- None
Changes for v11:
	- None
Changes for v12:
	- None
Changes for v13:
	- None
Changes for v14:
	- None
Changes for v15:
	- None
Changes for v16:
	- Added 'Acked-by: Arnd'
---
 arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi b/arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi
index 7f0dc13..d058e56 100644
--- a/arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi
+++ b/arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi
@@ -216,6 +216,12 @@
 			clocks = <&sysclk>;
 		};
 
+		dcfg: dcfg@1e00000 {
+			compatible = "fsl,ls2080a-dcfg", "syscon";
+			reg = <0x0 0x1e00000 0x0 0x10000>;
+			little-endian;
+		};
+
 		serial0: serial@21c0500 {
 			compatible = "fsl,ns16550", "ns16550a";
 			reg = <0x0 0x21c0500 0x0 0x100>;
-- 
2.1.0.27.g96db324
