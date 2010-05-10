From: kaber@trash.net
Subject: [PATCH 71/84] netfilter: ipt_LOG/ip6t_LOG: use more appropriate log level as default
Date: Mon, 10 May 2010 22:18:42 +0200
Message-ID: <1273522735-24672-72-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Use KERN_NOTICE instead of KERN_EMERG by default. This only affects
kernel internal logging (like conntrack), user-specified logging rules
contain a seperate log level.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_LOG.c  |    2 +-
 net/ipv6/netfilter/ip6t_LOG.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index a6a454b..3bd35f3 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -367,7 +367,7 @@ static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level    = 0,
+			.level    = 5,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 439eded..1f47a52 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -377,7 +377,7 @@ static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level	  = 0,
+			.level	  = 5,
 			.logflags = NF_LOG_MASK,
 		},
 	},
-- 
1.7.0.4

