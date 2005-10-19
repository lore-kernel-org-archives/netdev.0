From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc3 3/3] sundance: expand reset mask
Date: Tue, 18 Oct 2005 21:31:02 -0400
Message-ID: <10182005213102.12871@bilbo.tuxdriver.com>
References: <10182005213101.12810@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932441AbVJSBgM@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <10182005213101.12810@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Expand the mask used when reseting the chip to include the GlobalReset
bit.  This fix comes from ICPlus and seems to be required for some
cards.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/sundance.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -690,7 +690,7 @@ static int __devinit sundance_probe1 (st
 	/* Reset the chip to erase previous misconfiguration. */
 	if (netif_msg_hw(np))
 		printk("ASIC Control is %x.\n", ioread32(ioaddr + ASICCtrl));
-	iowrite16(0x007f, ioaddr + ASICCtrl + 2);
+	iowrite16(0x00ff, ioaddr + ASICCtrl + 2);
 	if (netif_msg_hw(np))
 		printk("ASIC Control is now %x.\n", ioread32(ioaddr + ASICCtrl));
 
