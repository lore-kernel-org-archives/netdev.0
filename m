From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] chelsio: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:45:09 +0800
Message-ID: <49A52135.30603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54428 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752224AbZBYKpk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:45:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/chelsio/sge.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 840da83..58f6fc0 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1967,8 +1967,7 @@ void t1_sge_stop(struct sge *sge)
 		tx_sched_stop(sge);
 
 	for (i = 0; i < MAX_NPORTS; i++)
-		if (sge->espibug_skb[i])
-			kfree_skb(sge->espibug_skb[i]);
+		kfree_skb(sge->espibug_skb[i]);
 }
 
 /*
-- 
1.5.3.8




