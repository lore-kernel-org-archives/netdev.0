From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v2 13/13] net: ethernet: aquantia: Integrate AQtion 2.5/5 GB NIC driver
Date: Mon,  9 Jan 2017 14:16:11 -0800
Message-ID: <66066b129bfac133b682dd4e4832004edf6615a0.1483999588.git.vomlehn@texas.net>
References: <cover.1483999588.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:42644 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933142AbdAIWRZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:17:25 -0500
In-Reply-To: <cover.1483999588.git.vomlehn@texas.net>
In-Reply-To: <703b9184b3216032657a7895bd71929d2031bbc4.1483999588.git.vomlehn@texas.net>
References: <cover.1483999588.git.vomlehn@texas.net> <0b0d8974bdbfa66ab3bc4460f32f7916dd54b85a.1483999588.git.vomlehn@texas.net> <6d32f594bb99a6f56f82f13f6aa54885a06b1e22.1483999588.git.vomlehn@texas.net> <6dfadde2e1fe39b46d814c83fb7460566e860095.1483999588.git.vomlehn@texas.net> <a24ccb1c19a30c6fd4492b54d32663225d0f6534.1483999588.git.vomlehn@texas.net> <8b8385cb2a8e856da001922d65009a4fcfc26295.1483999588.git.vomlehn@texas.net> <1ea4ddc9bb144b5809aec4e441d553ff3fe9c263.1483999588.git.vomlehn@texas.net> <5cf2494bfdb3e327dec2fdc7c50ae56fdac83a2f.1483999588.git.vomlehn@texas.net> <68bda8ddca6d16001ea990a5197cdcdaa4efa107.1483999588.git.vomlehn@texas.net> <c2d259cedda86684baf77e04c83ea675ee040bda.1483999588.git.vomlehn@texas.net> <7bc5005bb4345003d27e67df218fd4689aca0050.1483999588.git.vomleh
 n@texas.net> <2a2056f13b975c8a4924b4f733d3cdc28a6b9422.1483999588.git.vomlehn@texas.net> <703b9184b3216032657a7895bd71929d2031bbc4.1483999588.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Modify the drivers/net/ethernet/{Makefile,Kconfig} file to make them a
part of the network drivers build.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/Kconfig  | 1 +
 drivers/net/ethernet/Makefile | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 8cc7467..d467c8b 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -28,6 +28,7 @@ source "drivers/net/ethernet/amazon/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apm/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
+source "drivers/net/ethernet/aquantia/Kconfig"
 source "drivers/net/ethernet/arc/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
 source "drivers/net/ethernet/aurora/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index a09423d..123ef8e 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_NET_VENDOR_AMAZON) += amazon/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_XGENE) += apm/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
+obj-$(CONFIG_NET_VENDOR_AQUANTIA) += aquantia/
 obj-$(CONFIG_NET_VENDOR_ARC) += arc/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
 obj-$(CONFIG_NET_VENDOR_AURORA) += aurora/
-- 
2.7.4
