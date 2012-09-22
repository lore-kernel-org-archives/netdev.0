From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH] net/phy/bcm87xx: Add MODULE_LICENSE("GPL") to GPL driver
Date: Sat, 22 Sep 2012 04:44:18 +0200
Message-ID: <1348281858-24366-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Korsgaard <jacmet@sunsite.dk>,
	David Daney <david.daney@cavium.com>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Huewe <peterhuewe@gmx.de>, stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:37611 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932627Ab2IVCjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 22:39:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the driver has no MODULE_LICENSE attribute in its source which
results in a kernel taint if I load this:

root@(none):~# modprobe bcm87xx
bcm87xx: module license 'unspecified' taints kernel.

Since the first lines of the source code clearly state:
 * This file is subject to the terms and conditions of the GNU General
 * Public License.  See the file "COPYING" in the main directory of this
 * archive for more details.
I think it's safe to add the MODULE_LICENSE("GPL") macro and thus remove
the kernel taint.

Cc: stable@vger.kernel.org
Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/phy/bcm87xx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
index 2346b38..7997895 100644
--- a/drivers/net/phy/bcm87xx.c
+++ b/drivers/net/phy/bcm87xx.c
@@ -229,3 +229,5 @@ static void __exit bcm87xx_exit(void)
 		ARRAY_SIZE(bcm87xx_driver));
 }
 module_exit(bcm87xx_exit);
+
+MODULE_LICENSE("GPL");
-- 
1.7.8.6
