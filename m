From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/11] drivers/net/pcnet32.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:07 -0800
Message-ID: <8fd9b582c10ca4d7ba53b76f68f19b608d755843.1197671367.git.joe__21278.6305732608$1197671870$gmane$org@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
 <1197671652-32492-3-git-send-email-joe@perches.com>
 <1197671652-32492-4-git-send-email-joe@perches.com>
 <1197671652-32492-5-git-send-email-joe@perches.com>
Cc: Don Fry <pcnet32@verizon.net>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934112AbXLNWgM@vger.kernel.org>
In-Reply-To: <1197671652-32492-5-git-send-email-joe@perches.com>
Message-Id: <8fd9b582c10ca4d7ba53b76f68f19b608d755843.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pcnet32.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index ff92aca..87edeb6 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1769,8 +1769,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
 
 	if (pcnet32_debug & NETIF_MSG_PROBE) {
-		for (i = 0; i < 6; i++)
-			printk(" %2.2x", dev->dev_addr[i]);
+		DECLARE_MAC_BUF(mac);
+		printk(" %s", print_mac(mac, dev->dev_addr));
 
 		/* Version 0x2623 and 0x2624 */
 		if (((chip_version + 1) & 0xfffe) == 0x2624) {
-- 
1.5.3.7.949.g2221a6

