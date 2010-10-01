From: akpm@linux-foundation.org
Subject: [patch 2/2] drivers/net/stmmac/: add HAS_IOMEM dependency
Date: Fri, 01 Oct 2010 14:17:13 -0700
Message-ID: <201010012117.o91LHDCF021161@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	peppe.cavallaro@st.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52013 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756506Ab0JAVR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 17:17:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

The stmmac driver does not compile on s390:

drivers/net/stmmac/stmmac_main.c: In function 'stmmac_adjust_link':
drivers/net/stmmac/stmmac_main.c:210: error: implicit declaration of function 'readl'
drivers/net/stmmac/stmmac_main.c:263: error: implicit declaration of function 'writel'
drivers/net/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
drivers/net/stmmac/stmmac_main.c:1674: error: implicit declaration of function 'ioremap'
drivers/net/stmmac/stmmac_main.c:1674: warning: assignment makes pointer from integer without a cast
drivers/net/stmmac/stmmac_main.c:1761: error: implicit declaration of function 'iounmap'
make[3]: *** [drivers/net/stmmac/stmmac_main.o] Error 1

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/stmmac/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/stmmac/Kconfig~drivers-net-stmmac-add-has_iomem-dependency drivers/net/stmmac/Kconfig
--- a/drivers/net/stmmac/Kconfig~drivers-net-stmmac-add-has_iomem-dependency
+++ a/drivers/net/stmmac/Kconfig
@@ -3,7 +3,7 @@ config STMMAC_ETH
 	select MII
 	select PHYLIB
 	select CRC32
-	depends on NETDEVICES
+	depends on NETDEVICES && HAS_IOMEM
 	help
 	  This is the driver for the Ethernet IPs are built around a
 	  Synopsys IP Core and only tested on the STMicroelectronics
_
