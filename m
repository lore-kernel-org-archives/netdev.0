From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] iucv: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:41:03 +0800
Message-ID: <49A5203F.5060009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: Ursula Braun <ursula.braun@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50472 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756207AbZBYKlf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:41:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/iucv/af_iucv.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index eb8a2a0..49e7865 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1171,8 +1171,7 @@ static void iucv_callback_txdone(struct iucv_path *path,
 
 		spin_unlock_irqrestore(&list->lock, flags);
 
-		if (this)
-			kfree_skb(this);
+		kfree_skb(this);
 	}
 	BUG_ON(!this);
 
-- 
1.5.3.8




