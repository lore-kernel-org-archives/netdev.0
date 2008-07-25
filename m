From: "Gustavo F. Padovan" <gustavo@las.ic.unicamp.br>
Subject: [PATCH] drivers/net: Remove 'return' of void function NS8390p_init()
Date: Fri, 25 Jul 2008 02:13:02 -0300
Message-ID: <1216962782-32493-1-git-send-email-gustavo@las.ic.unicamp.br>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753297AbYGYFNU@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't need this into a void function.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
---
 drivers/net/8390p.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/8390p.c b/drivers/net/8390p.c
index 71f1988..fd46f6c 100644
--- a/drivers/net/8390p.c
+++ b/drivers/net/8390p.c
@@ -39,7 +39,7 @@ struct net_device *__alloc_eip_netdev(int size)
 
 void NS8390p_init(struct net_device *dev, int startp)
 {
-	return __NS8390_init(dev, startp);
+	__NS8390_init(dev, startp);
 }
 
 EXPORT_SYMBOL(eip_open);
-- 
1.5.4.5
