From: Ilya Yanok <yanok@emcraft.com>
Subject: [PATCH] dnet: DNET should depend on HAS_IOMEM
Date: Fri, 20 Mar 2009 14:06:25 +0300
Message-ID: <1237547185-20088-1-git-send-email-yanok@emcraft.com>
References: <20090320101401.6ea261ea@osiris.boeblingen.de.ibm.com>
Cc: sfr@canb.auug.org.au, davem@davemloft.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ilya Yanok <yanok@emcraft.com>
To: heiko.carstens@de.ibm.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090320101401.6ea261ea@osiris.boeblingen.de.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilya Yanok <yanok@emcraft.com>
---
 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 435e2e3..62d732a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1042,7 +1042,7 @@ config NI65
 
 config DNET
 	tristate "Dave ethernet support (DNET)"
-	depends on NET_ETHERNET
+	depends on NET_ETHERNET && HAS_IOMEM
 	select PHYLIB
 	help
 	  The Dave ethernet interface (DNET) is found on Qong Board FPGA.
-- 
1.6.2
