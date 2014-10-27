From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 net-next] ipx: remove __inline__ in c file on static
Date: Mon, 27 Oct 2014 21:12:08 +0100
Message-ID: <1414440728-6144-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let compiler decide what to do with static void __ipxitf_put()

Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: remove __inline__ instead of replacing it by standard inline
(suggested by David S. Miller)

 net/ipx/af_ipx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 91729b8..313ef46 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -306,7 +306,7 @@ void ipxitf_down(struct ipx_interface *intrfc)
 	spin_unlock_bh(&ipx_interfaces_lock);
 }
 
-static __inline__ void __ipxitf_put(struct ipx_interface *intrfc)
+static void __ipxitf_put(struct ipx_interface *intrfc)
 {
 	if (atomic_dec_and_test(&intrfc->refcnt))
 		__ipxitf_down(intrfc);
-- 
1.9.1
