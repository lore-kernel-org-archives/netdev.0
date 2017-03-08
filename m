From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] tun: remove copyright printing
Date: Wed,  8 Mar 2017 16:46:57 +0100
Message-ID: <20170308154657.8988-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Printing copyright does not give any useful information on the boot
process.
Furthermore, the email address printed is obsolete since
commit ba57b6f20429 ("MAINTAINERS: fix bouncing tun/tap entries")

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/tun.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index dc1b1dd..f58b7d8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2570,7 +2570,6 @@ static int __init tun_init(void)
 	int ret = 0;
 
 	pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
-	pr_info("%s\n", DRV_COPYRIGHT);
 
 	ret = rtnl_link_register(&tun_link_ops);
 	if (ret) {
-- 
2.10.2
