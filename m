From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] aeroflex: Fix typo in greth.c
Date: Thu,  9 Feb 2012 23:23:33 +0900
Message-ID: <1328797413-1740-1-git-send-email-standby24x7@gmail.com>
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	standby24x7@gmail.com
To: kristoffer@gaisler.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling "reseting" to "resetting" in
drivers/net/ethernet/aeroflex/greth.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/ethernet/aeroflex/greth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index b23751e..cfa1348 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1421,7 +1421,7 @@ static int __devinit greth_of_probe(struct platform_device *ofdev)
 	SET_NETDEV_DEV(dev, greth->dev);
 
 	if (netif_msg_probe(greth))
-		dev_dbg(greth->dev, "reseting controller.\n");
+		dev_dbg(greth->dev, "resetting controller.\n");
 
 	/* Reset the controller. */
 	GRETH_REGSAVE(regs->control, GRETH_RESET);
-- 
1.7.6.5
