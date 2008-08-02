From: "Gustavo F. Padovan" <gustavo@las.ic.unicamp.br>
Subject: [PATCH 1/3] drivers/net: Remove 'return' of void function NS8390p_init()
Date: Sat,  2 Aug 2008 15:55:11 -0300
Message-ID: <1217703313-23407-2-git-send-email-gustavo@las.ic.unicamp.br>
References: <gustavo@las.ic.unicamp.br>
 <1217703313-23407-1-git-send-email-gustavo@las.ic.unicamp.br>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: p_gortmaker@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from argonath.las.ic.unicamp.br ([143.106.60.116]:36303 "EHLO
	mail.las.ic.unicamp.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbYHBSzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 14:55:15 -0400
In-Reply-To: <1217703313-23407-1-git-send-email-gustavo@las.ic.unicamp.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

