From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/10] drivers/atm/eni.c: Remove multiple uses of KERN_<level>
Date: Mon, 25 Oct 2010 19:44:20 -0700
Message-ID: <0dc3cfe16f343ca6c6922a066e913a1fc4d89741.1288059486.git.joe@perches.com>
References: <cover.1288059486.git.joe@perches.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1288059486.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/atm/eni.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 80f9f36..97c5898 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1736,9 +1736,10 @@ static int __devinit eni_do_init(struct atm_dev *dev)
 		eprom = (base+EPROM_SIZE-sizeof(struct midway_eprom));
 		if (readl(&eprom->magic) != ENI155_MAGIC) {
 			printk("\n");
-			printk(KERN_ERR KERN_ERR DEV_LABEL "(itf %d): bad "
-			    "magic - expected 0x%x, got 0x%x\n",dev->number,
-			    ENI155_MAGIC,(unsigned) readl(&eprom->magic));
+			printk(KERN_ERR DEV_LABEL
+			       "(itf %d): bad magic - expected 0x%x, got 0x%x\n",
+			       dev->number, ENI155_MAGIC,
+			       (unsigned)readl(&eprom->magic));
 			error = -EINVAL;
 			goto unmap;
 		}
-- 
1.7.3.dirty
