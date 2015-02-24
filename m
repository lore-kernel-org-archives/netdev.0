From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 2/2] net: netcp: select davinci_mdio driver by default
Date: Tue, 24 Feb 2015 16:27:31 -0500
Message-ID: <1424813251-31610-2-git-send-email-m-karicheri2@ti.com>
References: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>
To: <davem@davemloft.net>, <mugunthanvnm@ti.com>,
	<george.cherian@ti.com>, <prabhakar.csengg@gmail.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <tony@atomide.com>,
	<grygorii.strashko@ti.com>, <lokeshvutla@ti.com>,
	<mpa@pengutronix.de>, <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keystone netcp driver re-uses davinci mdio driver. So enable it
by default for keystone netcp driver.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 3bc992c..945a221 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -88,6 +88,7 @@ config TI_CPTS
 config TI_KEYSTONE_NETCP
 	tristate "TI Keystone NETCP Core Support"
 	select TI_CPSW_ALE
+	select TI_DAVINCI_MDIO
 	depends on OF
 	depends on KEYSTONE_NAVIGATOR_DMA && KEYSTONE_NAVIGATOR_QMSS
 	---help---
-- 
1.7.9.5
