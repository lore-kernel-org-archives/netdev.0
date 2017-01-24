From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v8 13/13] net: ethernet: aquantia: Integrate AQtion 2.5/5 GB NIC driver
Date: Mon, 23 Jan 2017 22:09:20 -0800
Message-ID: <3b41980ba694bfc2f6aa3d58f5e6bf3dcfbbe8d9.1485237861.git.vomlehn@texas.net>
References: <cover.1485237861.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:44928 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750808AbdAXGKA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 01:10:00 -0500
In-Reply-To: <cover.1485237861.git.vomlehn@texas.net>
In-Reply-To: <cover.1485237861.git.vomlehn@texas.net>
References: <cover.1485237861.git.vomlehn@texas.net>
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
index e4c28fe..1258b55 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -29,6 +29,7 @@ source "drivers/net/ethernet/amazon/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apm/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
+source "drivers/net/ethernet/aquantia/Kconfig"
 source "drivers/net/ethernet/arc/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
 source "drivers/net/ethernet/aurora/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 24330f4..d8a33c7 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_NET_VENDOR_AMAZON) += amazon/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_XGENE) += apm/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
+obj-$(CONFIG_NET_VENDOR_AQUANTIA) += aquantia/
 obj-$(CONFIG_NET_VENDOR_ARC) += arc/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
 obj-$(CONFIG_NET_VENDOR_AURORA) += aurora/
-- 
2.9.3
