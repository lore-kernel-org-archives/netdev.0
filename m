From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/2] bonding: remove the unnecessary notes for bond_xmit_broadcast()
Date: Fri, 19 Sep 2014 21:05:01 +0800
Message-ID: <541C29FD.704@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Nikolay Aleksandrov <nikolay@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:50648 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756028AbaISNFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 09:05:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0324603..caf1ac8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3685,7 +3685,6 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 						    bond_dev->name, __func__);
 				continue;
 			}
-			/* bond_dev_queue_xmit always returns 0 */
 			bond_dev_queue_xmit(bond, skb2, slave->dev);
 		}
 	}
-- 
1.7.12
