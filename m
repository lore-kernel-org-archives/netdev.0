From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/62] can: Use static const
Date: Sat, 20 Nov 2010 18:38:10 -0800
Message-ID: <4f763de26328274655d53080c368c178a28771fa.1290305775.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   4399	    604	   1160	   6163	   1813	drivers/net/can/sja1000/plx_pci.o.old
   4396	    604	   1160	   6160	   1810	drivers/net/can/sja1000/plx_pci.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/can/sja1000/plx_pci.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index 437b5c7..231385b 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -383,7 +383,7 @@ static void plx_pci_reset_marathon(struct pci_dev *pdev)
 {
 	void __iomem *reset_addr;
 	int i;
-	int reset_bar[2] = {3, 5};
+	static const int reset_bar[2] = {3, 5};
 
 	plx_pci_reset_common(pdev);
 
-- 
1.7.3.2.245.g03276.dirty
