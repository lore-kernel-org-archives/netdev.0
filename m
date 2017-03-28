From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH] netfilter: ipset: Use max macro instead of ternary operator
Date: Tue, 28 Mar 2017 19:02:56 +0530
Message-ID: <20170328133256.GA24590@singhal-Inspiron-5558>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: outreachy-kernel@googlegroups.com,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces ternary operator with macro max as it shorter and
thus increases code readability. Macro max return the maximum of the two
compared values.

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---
 net/netfilter/ipset/ip_set_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 10a3694..248fef7 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -571,7 +571,7 @@ ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	}
 
 	/* Convert error codes to nomatch */
-	return (ret < 0 ? 0 : ret);
+	return max(0, ret);
 }
 EXPORT_SYMBOL_GPL(ip_set_test);
 
-- 
2.7.4
