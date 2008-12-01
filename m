From: "Eric Miao" <eric.y.miao@gmail.com>
Subject: [ARM] pxa: explicit #include <mach/dma.h> in various
	drivers
Date: Mon, 1 Dec 2008 11:49:35 +0800
Message-ID: <f17812d70811301949s6dc4bcddt791822f8d4ff223c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-mtd <linux-mtd@lists.infradead.org>
To: "ARM Linux" <linux-arm-kernel@lists.arm.linux.org.uk>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Where 'pxa_dma_desc' and 'pxa_{request,free}_dma' are referenced.

Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 drivers/mtd/nand/pxa3xx_nand.c |    2 +-
 drivers/net/smc911x.h          |    3 +++
 sound/arm/pxa2xx-pcm.h         |    2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/mtd/nand/pxa3xx_nand.c b/drivers/mtd/nand/pxa3xx_nand.c
index c0fa9c9..64b3be1 100644
--- a/drivers/mtd/nand/pxa3xx_nand.c
+++ b/drivers/mtd/nand/pxa3xx_nand.c
@@ -20,8 +20,8 @@
 #include <linux/mtd/partitions.h>
 #include <linux/io.h>
 #include <linux/irq.h>
-#include <asm/dma.h>

+#include <mach/dma.h>
 #include <mach/pxa-regs.h>
 #include <mach/pxa3xx_nand.h>

diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index cc7d85b..870b4c3 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -200,6 +200,9 @@ static inline void SMC_outsl(struct smc911x_local
*lp, int reg,


 #ifdef SMC_USE_PXA_DMA
+
+#include <mach/dma.h>
+
 /*
  * Define the request and free functions
  * These are unfortunately architecture specific as no generic allocation
diff --git a/sound/arm/pxa2xx-pcm.h b/sound/arm/pxa2xx-pcm.h
index 5c4a4d3..65f86b5 100644
--- a/sound/arm/pxa2xx-pcm.h
+++ b/sound/arm/pxa2xx-pcm.h
@@ -9,7 +9,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-#include <asm/dma.h>
+#include <mach/dma.h>

 struct pxa2xx_runtime_data {
 	int dma_ch;
-- 
1.6.0.4
