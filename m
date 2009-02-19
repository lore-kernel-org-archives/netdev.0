From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 09/12]Replace all DMA_28BIT_MASK micro with DMA_BIT_MASK(28)
Date: Thu, 19 Feb 2009 14:51:06 +0800
Message-ID: <499D015A.5070807@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58100 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756210AbZBSGuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 01:50:50 -0500
In-Reply-To: <499CFDC8.1070600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_28BIT_MASK micro with DMA_BIT_MASK(28)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 drivers/net/wan/wanxl.c      |    4 ++--
 sound/pci/als300.c           |    4 ++--
 sound/pci/emu10k1/emu10k1x.c |    4 ++--
 sound/pci/es1968.c           |    4 ++--
 sound/pci/ice1712/ice1712.c  |    4 ++--
 sound/pci/maestro3.c         |    4 ++--
 6 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index f1cef90..c94edaa 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -577,8 +577,8 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	   We set both dma_mask and consistent_dma_mask to 28 bits
 	   and pray pci_alloc_consistent() will use this info. It should
 	   work on most platforms */
-	if (pci_set_consistent_dma_mask(pdev, DMA_28BIT_MASK) ||
-	    pci_set_dma_mask(pdev, DMA_28BIT_MASK)) {
+	if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(28)) ||
+	    pci_set_dma_mask(pdev, DMA_BIT_MASK(28))) {
 		printk(KERN_ERR "wanXL: No usable DMA configuration\n");
 		return -EIO;
 	}
diff --git a/sound/pci/als300.c b/sound/pci/als300.c
index 8df6824..88bef04 100644
--- a/sound/pci/als300.c
+++ b/sound/pci/als300.c
@@ -689,8 +689,8 @@ static int __devinit snd_als300_create(struct snd_card *card,
 	if ((err = pci_enable_device(pci)) < 0)
 		return err;
 
-	if (pci_set_dma_mask(pci, DMA_28BIT_MASK) < 0 ||
-		pci_set_consistent_dma_mask(pci, DMA_28BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
+		pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
 		printk(KERN_ERR "error setting 28bit DMA mask\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/emu10k1/emu10k1x.c b/sound/pci/emu10k1/emu10k1x.c
index 5ff4dbb..d1422e0 100644
--- a/sound/pci/emu10k1/emu10k1x.c
+++ b/sound/pci/emu10k1/emu10k1x.c
@@ -897,8 +897,8 @@ static int __devinit snd_emu10k1x_create(struct snd_card *card,
 
 	if ((err = pci_enable_device(pci)) < 0)
 		return err;
-	if (pci_set_dma_mask(pci, DMA_28BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_28BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
 		snd_printk(KERN_ERR "error to set 28bit mask DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/es1968.c b/sound/pci/es1968.c
index e9c3794..f4e124d 100644
--- a/sound/pci/es1968.c
+++ b/sound/pci/es1968.c
@@ -2539,8 +2539,8 @@ static int __devinit snd_es1968_create(struct snd_card *card,
 	if ((err = pci_enable_device(pci)) < 0)
 		return err;
 	/* check, if we can restrict PCI DMA transfers to 28 bits */
-	if (pci_set_dma_mask(pci, DMA_28BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_28BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support 28bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/ice1712/ice1712.c b/sound/pci/ice1712/ice1712.c
index 58d7cda..155c41e 100644
--- a/sound/pci/ice1712/ice1712.c
+++ b/sound/pci/ice1712/ice1712.c
@@ -2533,8 +2533,8 @@ static int __devinit snd_ice1712_create(struct snd_card *card,
 	if (err < 0)
 		return err;
 	/* check, if we can restrict PCI DMA transfers to 28 bits */
-	if (pci_set_dma_mask(pci, DMA_28BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_28BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support 28bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
diff --git a/sound/pci/maestro3.c b/sound/pci/maestro3.c
index 59bbaf8..a3e9f6c 100644
--- a/sound/pci/maestro3.c
+++ b/sound/pci/maestro3.c
@@ -2530,8 +2530,8 @@ snd_m3_create(struct snd_card *card, struct pci_dev *pci,
 		return -EIO;
 
 	/* check, if we can restrict PCI DMA transfers to 28 bits */
-	if (pci_set_dma_mask(pci, DMA_28BIT_MASK) < 0 ||
-	    pci_set_consistent_dma_mask(pci, DMA_28BIT_MASK) < 0) {
+	if (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
+	    pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
 		snd_printk(KERN_ERR "architecture does not support 28bit PCI busmaster DMA\n");
 		pci_disable_device(pci);
 		return -ENXIO;
-- 
1.6.0.3


-- 
Regards
Yang Hongyang
