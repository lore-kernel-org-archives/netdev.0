From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 02/25] netns ct: export netns list
Date: Sun, 22 Jun 2008 05:00:39 +0400
Message-ID: <20080622010039.GC5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Connection tracking code will use it for
a) nuking expectations and helpers when module is removed, and
b) removing conntracks when L3 protocol conntrack module is removed

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/net_namespace.c |    1 +
 1 file changed, 1 insertion(+)

--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -18,6 +18,7 @@ static struct list_head *first_device = &pernet_list;
 static DEFINE_MUTEX(net_mutex);
 
 LIST_HEAD(net_namespace_list);
+EXPORT_SYMBOL_GPL(net_namespace_list);
 
 struct net init_net;
 EXPORT_SYMBOL(init_net);
-- 
1.5.4.5


