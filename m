From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] i2400m: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:20:29 +0800
Message-ID: <49A51B6D.2070107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-wimax@intel.com, netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49339 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754041AbZBYKV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:21:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/wimax/i2400m/rx.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 6922022..c62b8c5 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -177,8 +177,7 @@ void i2400m_rx_ctl_ack(struct i2400m *i2400m,
 	return;
 
 error_waiter_cancelled:
-	if (ack_skb)
-		kfree_skb(ack_skb);
+	kfree_skb(ack_skb);
 error_no_waiter:
 	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 	return;
-- 
1.5.3.8




