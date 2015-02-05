From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] net/macb: fix sparse warning
Date: Thu,  5 Feb 2015 15:40:46 +0000
Message-ID: <1423150846-7027-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

macb.c:2038:26: warning: symbol 'gem_ethtool_ops' was not declared. Should it be static?

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.8.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/cadence/macb.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 31dc080..e6ad68a 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -821,6 +821,7 @@ struct macb {
 };
 
 extern const struct ethtool_ops macb_ethtool_ops;
+extern const struct ethtool_ops gem_ethtool_ops;
 
 int macb_mii_init(struct macb *bp);
 int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-- 
1.9.1
