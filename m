From: adobriyan@gmail.com
Subject: [PATCH 17/38] netns ct: export netns list
Date: Fri, 22 Aug 2008 02:03:22 +0400
Message-ID: <20080821220322.GQ31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Conntrack code will use it for
a) removing expectations and helpers when corresponding module is removed, and
b) removing conntracks when L3 protocol conntrack module is removed.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/net_namespace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -18,6 +18,7 @@ static struct list_head *first_device = &pernet_list;
 static DEFINE_MUTEX(net_mutex);
 
 LIST_HEAD(net_namespace_list);
+EXPORT_SYMBOL_GPL(net_namespace_list);
 
 struct net init_net;
 EXPORT_SYMBOL(init_net);
-- 
1.5.6.3


