From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 6/7] 2.6.5-bk-netdev - r8169 queue
Date: Mon, 5 Apr 2004 23:59:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405235959.F23436@electric-eye.fr.zoreil.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com> <20040405235648.A23436@electric-eye.fr.zoreil.com> <20040405235726.B23436@electric-eye.fr.zoreil.com> <20040405235802.C23436@electric-eye.fr.zoreil.com> <20040405235844.D23436@electric-eye.fr.zoreil.com> <20040405235929.E23436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040405235929.E23436@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Apr 05, 2004 at 11:59:29PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


DMA_{32/64}BIT_MASK for all.


 include/linux/dma-mapping.h |    3 +++
 1 files changed, 3 insertions(+)

diff -puN include/linux/dma-mapping.h~r8169-dac-00 include/linux/dma-mapping.h
--- linux-2.6.5/include/linux/dma-mapping.h~r8169-dac-00	2004-04-05 23:06:28.000000000 +0200
+++ linux-2.6.5-fr/include/linux/dma-mapping.h	2004-04-05 23:06:28.000000000 +0200
@@ -10,6 +10,9 @@ enum dma_data_direction {
 	DMA_NONE = 3,
 };
 
+#define DMA_64BIT_MASK 0xffffffffffffffffULL
+#define DMA_32BIT_MASK 0x00000000ffffffffULL
+
 #include <asm/dma-mapping.h>
 
 /* Backwards compat, remove in 2.7.x */

_
