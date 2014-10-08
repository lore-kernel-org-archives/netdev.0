From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] netlabel: directly return netlbl_unlabel_genl_init()
Date: Wed,  8 Oct 2014 20:37:01 +0200
Message-ID: <1412793421-9914-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Paul Moore <paul@paul-moore.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to store netlbl_unlabel_genl_init result and test it before returning.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/netlabel/netlabel_user.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index 1e779bb..adf8b79 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -71,11 +71,7 @@ int __init netlbl_netlink_init(void)
 	if (ret_val != 0)
 		return ret_val;
 
-	ret_val = netlbl_unlabel_genl_init();
-	if (ret_val != 0)
-		return ret_val;
-
-	return 0;
+	return netlbl_unlabel_genl_init();
 }
 
 /*
-- 
1.9.1
