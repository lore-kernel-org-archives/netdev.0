From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc1-mm1-tso 2/2] 8139cp: DAC support fix
Date: Mon, 30 Aug 2004 23:58:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830215818.GB26455@electric-eye.fr.zoreil.com>
References: <20040829212205.GA2864@havoc.gtf.org> <20040829222831.GA9496@electric-eye.fr.zoreil.com> <41326079.9090402@pobox.com> <20040830215227.GA23857@electric-eye.fr.zoreil.com> <20040830215636.GA26455@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040830215636.GA26455@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Wrong unit for sizeof().

diff -puN drivers/net/8139cp.c~8139cp-020 drivers/net/8139cp.c
--- linux-2.6.9-rc1/drivers/net/8139cp.c~8139cp-020	2004-08-30 23:34:16.000000000 +0200
+++ linux-2.6.9-rc1-fr/drivers/net/8139cp.c	2004-08-30 23:35:09.000000000 +0200
@@ -1711,7 +1711,7 @@ static int cp_init_one (struct pci_dev *
 	}
 
 	/* Configure DMA attributes. */
-	if ((sizeof(dma_addr_t) > 32) &&
+	if ((sizeof(dma_addr_t) > 4) &&
 	    !pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL) &&
 	    !pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
 		pci_using_dac = 1;

_
