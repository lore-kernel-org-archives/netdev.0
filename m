From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 10/33] net: dummy - set name assign type
Date: Thu, 10 Jul 2014 10:17:15 +0200
Message-ID: <1404980258-30853-11-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	dingtianhong <dingtianhong@huawei.com>,
	Tan Xiaojun <tanxiaojun@huawei.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A fixed number of indistinguishable dummy devices are allocated at module init time,
the names are therefore PREDICTABLE rather than ENUM.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: dingtianhong <dingtianhong@huawei.com>
Cc: Tan Xiaojun <tanxiaojun@huawei.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>
---
 drivers/net/dummy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index ff435fb..3eef710 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -164,7 +164,7 @@ static int __init dummy_init_one(void)
 	struct net_device *dev_dummy;
 	int err;
 
-	dev_dummy = alloc_netdev(0, "dummy%d", NET_NAME_UNKNOWN, dummy_setup);
+	dev_dummy = alloc_netdev(0, "dummy%d", NET_NAME_PREDICTABLE, dummy_setup);
 	if (!dev_dummy)
 		return -ENOMEM;
 
-- 
1.9.3
