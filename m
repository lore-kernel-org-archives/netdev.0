From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch] 2.6.5-rc2 - r8169 DAC
Date: Sat, 3 Apr 2004 10:19:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040403101954.A18810@electric-eye.fr.zoreil.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com> <20040329223513.C4744@electric-eye.fr.zoreil.com> <20040403010045.A12904@electric-eye.fr.zoreil.com> <200404031208.17066.harisri@bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, Andi Kleen <ak@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <harisri@bigpond.com>
Content-Disposition: inline
In-Reply-To: <200404031208.17066.harisri@bigpond.com>; from harisri@bigpond.com on Sat, Apr 03, 2004 at 12:08:16PM +1000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <harisri@bigpond.com> :
[compile error message]


DMA_{32/64}BIT_MASK for all.


 include/linux/dma-mapping.h |    3 +++
 1 files changed, 3 insertions(+)

diff -puN include/linux/dma-mapping.h~r8169-dac-00 include/linux/dma-mapping.h
--- linux-2.6.5-rc2/include/linux/dma-mapping.h~r8169-dac-00	2004-04-03 00:29:17.000000000 +0200
+++ linux-2.6.5-rc2-fr/include/linux/dma-mapping.h	2004-04-03 00:29:17.000000000 +0200
@@ -10,6 +10,9 @@ enum dma_data_direction {
 	DMA_NONE = 3,
 };
 
+#define DMA_64BIT_MASK 0xffffffffffffffffULL
+#define DMA_32BIT_MASK 0x00000000ffffffffULL
+
 #include <asm/dma-mapping.h>
 
 /* Backwards compat, remove in 2.7.x */

_
