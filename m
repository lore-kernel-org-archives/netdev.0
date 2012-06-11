From: pablo@netfilter.org
Subject: [PATCH 24/25] netfilter: ipvs: switch hook PFs to nfproto
Date: Mon, 11 Jun 2012 16:44:00 +0200
Message-ID: <1339425841-24171-25-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

This patch is a cleanup. Use NFPROTO_* for consistency with other
netfilter code.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_core.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a54b018c..b54ecce 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1742,7 +1742,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_reply4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC - 2,
 	},
@@ -1752,7 +1752,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_remote_request4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC - 1,
 	},
@@ -1760,7 +1760,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_reply4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST + 1,
 	},
@@ -1768,7 +1768,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_request4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST + 2,
 	},
@@ -1777,7 +1777,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_forward_icmp,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 99,
 	},
@@ -1785,7 +1785,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_reply4,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
 	},
@@ -1794,7 +1794,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_reply6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC - 2,
 	},
@@ -1804,7 +1804,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_remote_request6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC - 1,
 	},
@@ -1812,7 +1812,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_reply6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 1,
 	},
@@ -1820,7 +1820,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_request6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 2,
 	},
@@ -1829,7 +1829,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_forward_icmp_v6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 99,
 	},
@@ -1837,7 +1837,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_reply6,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
 	},
-- 
1.7.10

