From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] net/dccp/ccid.c: add __init to ccid_activate
Date: Wed,  1 Oct 2014 06:52:06 +0200
Message-ID: <1412139126-3794-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	"David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ccid_activate is only called by __init ccid_initialize_builtins in same module.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dccp/ccid.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 5975572..8349897 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -99,7 +99,7 @@ static void ccid_kmem_cache_destroy(struct kmem_cache *slab)
 		kmem_cache_destroy(slab);
 }
 
-static int ccid_activate(struct ccid_operations *ccid_ops)
+static int __init ccid_activate(struct ccid_operations *ccid_ops)
 {
 	int err = -ENOBUFS;
 
-- 
1.9.3
