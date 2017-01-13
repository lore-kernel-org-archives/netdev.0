From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v5 13/13] net: ethernet: aquantia: Integrate AQtion 2.5/5 GB NIC driver
Date: Thu, 12 Jan 2017 21:02:29 -0800
Message-ID: <93d0334dcaa6479cd438eb4c11425d84cc6df7f0.1484283610.git.vomlehn@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:53742 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751090AbdAMFDa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 00:03:30 -0500
In-Reply-To: <cover.1484283610.git.vomlehn@texas.net>
In-Reply-To: <c54a5830be99bc8f7ecbb4408bbc6b979b056c6a.1484283610.git.vomlehn@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net> <fe1664e502d28bcb6a5689787b8000e6c9288307.1484283610.git.vomlehn@texas.net> <2c056fd544958594f6356a17892c251ea26ea8c8.1484283610.git.vomlehn@texas.net> <98a7a3c6800c246753ef6cfaa5982a348da757c8.1484283610.git.vomlehn@texas.net> <29b795c8c4fc8de7925e82e071e5feaa266cd801.1484283610.git.vomlehn@texas.net> <5e87af3b0effb96698d0c085366b1ba9320a6305.1484283610.git.vomlehn@texas.net> <e17f53f9485f69edafa966d2bcbaa4b9fd7c145f.1484283610.git.vomlehn@texas.net> <e3f7eda0cc3bfa3426932c39465971ba4c6226ef.1484283610.git.vomlehn@texas.net> <2889e8e87b8b89945f34e57a7f8ca253f204de47.1484283610.git.vomlehn@texas.net> <fef6ab77998a2914f94549367b88ab31e1f734e7.1484283610.git.vomlehn@texas.net> <bd4244af243c5800bd08cfe6c3859f1b406089be.1484283610.git.vomleh
 n@texas.net> <b2236a13fcf9ac65f15cfc084de670948517e003.1484283610.git.vomlehn@texas.net> <c54a5830be99bc8f7ecbb4408bbc6b979b056c6a.1484283610.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Modify the drivers/net/ethernet/{Makefile,Kconfig} file to make them a
part of the network drivers build.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
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
