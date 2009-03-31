From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] core: remove pointless conditional before kfree()
Date: Tue, 31 Mar 2009 16:09:19 +0800
Message-ID: <49D1CFAF.4030109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65207 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752455AbZCaIKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 04:10:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove pointless conditional before kfree().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/core/ethtool.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 244ca56..d9d5160 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -261,8 +261,7 @@ static int ethtool_get_rxnfc(struct net_device *dev, void __user *useraddr)
 	ret = 0;
 
 err_out:
-	if (rule_buf)
-		kfree(rule_buf);
+	kfree(rule_buf);
 
 	return ret;
 }
-- 
1.5.3.8




