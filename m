From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 3/5] net: netcp: select davinci_mdio driver by default
Date: Fri, 20 Mar 2015 16:11:23 -0400
Message-ID: <1426882285-4873-4-git-send-email-m-karicheri2@ti.com>
References: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>,
	WingMan Kwok <w-kwok2@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Christoph Jaeger <cj@linux.com>,
	Lokesh Vutla <lokeshvutla@ti.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keystone netcp driver re-uses davinci mdio driver. So enable it
by default for keystone netcp driver.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Mugunthan V N <mugunthanvnm@ti.com>
CC: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
CC: Grygorii Strashko <grygorii.strashko@ti.com>
CC: Christoph Jaeger <cj@linux.com>
CC: Lokesh Vutla <lokeshvutla@ti.com>
CC: Markus Pargmann <mpa@pengutronix.de>
CC: Kumar Gala <galak@codeaurora.org>
CC: Ian Campbell <ijc+devicetree@hellion.org.uk>
CC: Mark Rutland <mark.rutland@arm.com>
CC: Pawel Moll <pawel.moll@arm.com>
CC: Rob Herring <robh+dt@kernel.org>
---
 drivers/net/ethernet/ti/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index f6a7109..631e0af 100644
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
