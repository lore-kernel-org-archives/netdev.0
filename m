From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Net, decnet: remove unused variable from dn_output()
Date: Sun, 5 Feb 2012 23:28:57 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1202052327050.32529@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Steve Whitehouse <SteveW@ACM.org>,
	Eduardo Marcelo Serrat <emserrat@geocities.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable 'neigh' is assigned to, but otherwise completely
unused. So let's remove it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/decnet/dn_route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index f31ce72..80a3de4 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -724,11 +724,10 @@ static int dn_output(struct sk_buff *skb)
 	struct dn_route *rt = (struct dn_route *)dst;
 	struct net_device *dev = dst->dev;
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
-	struct neighbour *neigh;
 
 	int err = -EINVAL;
 
-	if ((neigh = dst_get_neighbour_noref(dst)) == NULL)
+	if (dst_get_neighbour_noref(dst) == NULL)
 		goto error;
 
 	skb->dev = dev;
-- 
1.7.9


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
