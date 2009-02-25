From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] unix: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:32:45 +0800
Message-ID: <49A51E4D.6060500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62011 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759396AbZBYKdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:33:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/unix/af_unix.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d1b8982..baac910 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1178,8 +1178,7 @@ out_unlock:
 		unix_state_unlock(other);
 
 out:
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 	if (newsk)
 		unix_release_sock(newsk, 0);
 	if (other)
-- 
1.5.3.8




