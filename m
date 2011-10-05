From: Nathan Williams <nathan@traverse.com.au>
Subject: [PATCH 2/4] atm: solos-pci: Remove annoying line of debugging
Date: Wed, 05 Oct 2011 15:44:17 +1100
Message-ID: <1317789857.2424.86.camel@dualcore.traverse>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net,
	David Woodhouse <dwmw2@infradead.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"len: %d" isn't particularly useful for anyone and confuses users.

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
---
 drivers/atm/solos-pci.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 5d1d076..bd01aa3 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -452,7 +452,6 @@ static ssize_t console_show(struct device *dev, struct device_attribute *attr,
 
 	len = skb->len;
 	memcpy(buf, skb->data, len);
-	dev_dbg(&card->dev->dev, "len: %d\n", len);
 
 	kfree_skb(skb);
 	return len;
-- 
1.7.2.5
