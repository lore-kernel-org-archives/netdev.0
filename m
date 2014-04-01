From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 3/3] net: sxgbe: make "core_ops" static
Date: Tue, 1 Apr 2014 16:39:18 +0300
Message-ID: <20140401133918.GA11087@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Girish K S <ks.giri@samsung.com>,
	Siva Reddy Kallam <siva.kallam@samsung.com>,
	Vipul Pandya <vipul.pandya@samsung.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "core_ops" variable isn't referenced outside this file and Sparse
complains about it:

	drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c:239:29: warning:
	symbol 'core_ops' was not declared. Should it be static?

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
index 2e11da0..c4da7a2 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
@@ -236,7 +236,7 @@ static void sxgbe_disable_rx_csum(void __iomem *ioaddr)
 	writel(ctrl, ioaddr + SXGBE_CORE_RX_CONFIG_REG);
 }
 
-const struct sxgbe_core_ops core_ops = {
+static const struct sxgbe_core_ops core_ops = {
 	.core_init		= sxgbe_core_init,
 	.dump_regs		= sxgbe_core_dump_regs,
 	.host_irq_status	= sxgbe_core_host_irq_status,
