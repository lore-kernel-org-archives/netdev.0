From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: ks8851-ml: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 06:10:10 +0200
Message-ID: <1379045410-6687-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/micrel/ks8851_mll.c

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/micrel/ks8851_mll.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 0fba153..075f4e2 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -915,7 +915,7 @@ static int ks_net_open(struct net_device *netdev)
 	struct ks_net *ks = netdev_priv(netdev);
 	int err;
 
-#define	KS_INT_FLAGS	(IRQF_DISABLED|IRQF_TRIGGER_LOW)
+#define	KS_INT_FLAGS	IRQF_TRIGGER_LOW
 	/* lock the card, even if we may not actually do anything
 	 * else at the moment.
 	 */
-- 
1.8.1.2
