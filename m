From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v4 13/13] net: ethernet: aquantia: Integrate AQtion 2.5/5 GB NIC driver
Date: Wed, 11 Jan 2017 19:53:17 -0800
Message-ID: <c7f36ef42ccf6551a0701dcb8a7a49b3eaa2de0d.1484192452.git.vomlehn@texas.net>
References: <cover.1484192452.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:43862 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750745AbdALDyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 22:54:22 -0500
In-Reply-To: <cover.1484192452.git.vomlehn@texas.net>
In-Reply-To: <4f74abb3a4b2cab8acf0c6c5ddb5fffd0bf51be8.1484192452.git.vomlehn@texas.net>
References: <cover.1484192452.git.vomlehn@texas.net> <c1ad2600fae843ad7f21a7eb41a096aa3cdf239b.1484192452.git.vomlehn@texas.net> <20a9e54c90f44662be120d9c863a89f1ffe340e5.1484192452.git.vomlehn@texas.net> <6c34bc1f4f4a63732a5c6ac960eb78c55646be06.1484192452.git.vomlehn@texas.net> <317cced5b487a46d728e731f967bf6231ea453ec.1484192452.git.vomlehn@texas.net> <2287a0a40f4c507fa650ee2750d613c28fbb57a7.1484192452.git.vomlehn@texas.net> <b96fe90743466d671a2ac5a741118059cdeb5f1a.1484192452.git.vomlehn@texas.net> <14143df0838ee18962e5df714d31b683afe44077.1484192452.git.vomlehn@texas.net> <4218cb42d4819ff59f24b3a3b28d2621c549f202.1484192452.git.vomlehn@texas.net> <c3773612a6b9bef64addd3f88d3920ec8dd68daa.1484192452.git.vomlehn@texas.net> <868d6d2e2defa8a4d9d0dc66e575c8a7b64cc72b.1484192452.git.vomleh
 n@texas.net> <b9cf8d650c93e1d827597c87d4928d98759736f7.1484192452.git.vomlehn@texas.net> <4f74abb3a4b2cab8acf0c6c5ddb5fffd0bf51be8.1484192452.git.vomlehn@texas.net>
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
