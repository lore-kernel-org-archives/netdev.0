From: Claudiu Ghioc <claudiughioc@gmail.com>
Subject: [PATCH] ipvs: fixed sparse warning
Date: Fri, 13 Jul 2012 19:57:22 +0300
Message-ID: <1342198642-22741-1-git-send-email-claudiu.ghioc@gmail.com>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org,
	kaber@trash.net, Claudiu Ghioc <claudiu.ghioc@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed the following sparse warnings:
*	warning: symbol 'ip_vs_control_net_init_sysctl' was not declared. Should
	it be static?
*	warning: symbol 'ip_vs_control_net_cleanup_sysctl' was not
	declared. Should it be static?

Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d43e3c1..3542c6b1 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3674,7 +3674,7 @@ static void ip_vs_genl_unregister(void)
  * per netns intit/exit func.
  */
 #ifdef CONFIG_SYSCTL
-int __net_init ip_vs_control_net_init_sysctl(struct net *net)
+static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 {
 	int idx;
 	struct netns_ipvs *ipvs = net_ipvs(net);
@@ -3742,7 +3742,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	return 0;
 }
 
-void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
+static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-- 
1.7.10.4

