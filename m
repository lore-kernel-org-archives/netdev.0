From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 6/6] ARM: dts: keystone: enable time synchronization (cpts) submodule
Date: Mon, 28 Nov 2016 17:04:28 -0600
Message-ID: <20161128230428.6872-7-grygorii.strashko@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128230428.6872-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds DT configuration for Time Synchronization (CPTS) submodule
which is present on KeyStone 66AK2HK/E/Lx 1G Switch Subsystem.
The SYSCLK2 is selected as CPTS rftclk by default.
The ts_comp enabled for 66AK2E/L SoCs.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 arch/arm/boot/dts/keystone-k2e-netcp.dtsi  | 3 +++
 arch/arm/boot/dts/keystone-k2hk-netcp.dtsi | 1 +
 arch/arm/boot/dts/keystone-k2l-netcp.dtsi  | 3 +++
 3 files changed, 7 insertions(+)

diff --git a/arch/arm/boot/dts/keystone-k2e-netcp.dtsi b/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
index ba828cb..919e655 100644
--- a/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
+++ b/arch/arm/boot/dts/keystone-k2e-netcp.dtsi
@@ -158,6 +158,9 @@ netcp: netcp@24000000 {
 			/* enable-ale; */
 			tx-queue = <896>;
 			tx-channel = "nettx";
+			cpts-rftclk-sel = <0>;
+			cpts-ext-ts-inputs = <6>;
+			cpts-ts-comp-length;
 
 			interfaces {
 				gbe0: interface-0 {
diff --git a/arch/arm/boot/dts/keystone-k2hk-netcp.dtsi b/arch/arm/boot/dts/keystone-k2hk-netcp.dtsi
index a5ac845..772097b 100644
--- a/arch/arm/boot/dts/keystone-k2hk-netcp.dtsi
+++ b/arch/arm/boot/dts/keystone-k2hk-netcp.dtsi
@@ -177,6 +177,7 @@ netcp: netcp@2000000 {
 			/* enable-ale; */
 			tx-queue = <648>;
 			tx-channel = "nettx";
+			cpts-rftclk-sel = <0>;
 
 			interfaces {
 				gbe0: interface-0 {
diff --git a/arch/arm/boot/dts/keystone-k2l-netcp.dtsi b/arch/arm/boot/dts/keystone-k2l-netcp.dtsi
index b6f2682..580e2b2 100644
--- a/arch/arm/boot/dts/keystone-k2l-netcp.dtsi
+++ b/arch/arm/boot/dts/keystone-k2l-netcp.dtsi
@@ -157,6 +157,9 @@ netcp: netcp@26000000 {
 			/* enable-ale; */
 			tx-queue = <896>;
 			tx-channel = "nettx";
+			cpts-rftclk-sel = <0>;
+			cpts-ext-ts-inputs = <6>;
+			cpts-ts-comp-length;
 
 			interfaces {
 				gbe0: interface-0 {
-- 
2.10.1
