From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: ipmr: make function ipmr_notifier_init static
Date: Fri, 29 Sep 2017 14:34:22 +0100
Message-ID: <20170929133422.7846-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The function ipmr_notifier_init is local to the source and does
not need to be in global scope, so make it static.

Cleans up sparse warning:
warning: symbol 'ipmr_notifier_init' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv4/ipmr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 292a8e80bdfa..a844738b38bd 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -3224,7 +3224,7 @@ static const struct fib_notifier_ops ipmr_notifier_ops_template = {
 	.owner		= THIS_MODULE,
 };
 
-int __net_init ipmr_notifier_init(struct net *net)
+static int __net_init ipmr_notifier_init(struct net *net)
 {
 	struct fib_notifier_ops *ops;
 
-- 
2.14.1
