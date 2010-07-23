From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] xt_helper: use ARRAY_SIZE()
Date: Fri, 23 Jul 2010 17:24:49 +0800
Message-ID: <1279877089-18307-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use ARRAY_SIZE() to improve the readability.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/netfilter/xt_helper.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 9f4ab00..805c9f6 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -65,7 +65,7 @@ static int helper_mt_check(const struct xt_mtchk_param *par)
 			par->family);
 		return ret;
 	}
-	info->name[29] = '\0';
+	info->name[ARRAY_SIZE(info->name) - 1] = '\0';
 	return 0;
 }
 
