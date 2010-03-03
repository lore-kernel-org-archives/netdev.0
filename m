From: Dan Carpenter <error27@gmail.com>
Subject: [patch] cassini: fix off by one
Date: Wed, 3 Mar 2010 11:22:41 +0300
Message-ID: <20100303082241.GA32640@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Hongyang <yanghy@cn.fujitsu.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are only 6 link_modes.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 7cbcfb0..9bd155e 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -5072,7 +5072,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 	INIT_WORK(&cp->reset_task, cas_reset_task);
 
 	/* Default link parameters */
-	if (link_mode >= 0 && link_mode <= 6)
+	if (link_mode >= 0 && link_mode < 6)
 		cp->link_cntl = link_modes[link_mode];
 	else
 		cp->link_cntl = BMCR_ANENABLE;
