From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH net-next 4/4] dtb: xgene: Add irqs to support multi queue
Date: Tue,  2 Feb 2016 23:55:16 -0800
Message-ID: <1454486116-23783-5-git-send-email-isubramanian@apm.com>
References: <1454486116-23783-1-git-send-email-isubramanian@apm.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, toanle-qTEPVZfXA3Y@public.gmane.org,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Khuong Dinh <kdinh-qTEPVZfXA3Y@public.gmane.org>, Tanmay Inamdar <tinamdar-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454486116-23783-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Khuong Dinh <kdinh-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Tanmay Inamdar <tinamdar-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
---
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi | 8 +++++++-
 arch/arm64/boot/dts/apm/apm-storm.dtsi     | 8 +++++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
index 5d87a3d..278f106 100644
--- a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
@@ -621,7 +621,13 @@
 			      <0x0 0x1f600000 0x0 0Xd100>,
 			      <0x0 0x20000000 0x0 0X220000>;
 			interrupts = <0 108 4>,
-				     <0 109 4>;
+				     <0 109 4>,
+				     <0 110 4>,
+				     <0 111 4>,
+				     <0 112 4>,
+				     <0 113 4>,
+				     <0 114 4>,
+				     <0 115 4>;
 			port-id = <1>;
 			dma-coherent;
 			clocks = <&xge1clk 0>;
diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index fe30f76..cafb2c2 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -958,7 +958,13 @@
 			      <0x0 0x18000000 0x0 0X200>;
 			reg-names = "enet_csr", "ring_csr", "ring_cmd";
 			interrupts = <0x0 0x60 0x4>,
-				     <0x0 0x61 0x4>;
+				     <0x0 0x61 0x4>,
+				     <0x0 0x62 0x4>,
+				     <0x0 0x63 0x4>,
+				     <0x0 0x64 0x4>,
+				     <0x0 0x65 0x4>,
+				     <0x0 0x66 0x4>,
+				     <0x0 0x67 0x4>;
 			dma-coherent;
 			clocks = <&xge0clk 0>;
 			/* mac address will be overwritten by the bootloader */
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
