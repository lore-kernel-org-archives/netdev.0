From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/12] netfilter: bridge: rename br_netfilter.c to br_netfilter_hooks.c
Date: Fri, 19 Jun 2015 19:17:41 +0200
Message-ID: <1434734269-4545-5-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To prepare separation of the IPv6 code into different file.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/Makefile                                 |    1 +
 net/bridge/{br_netfilter.c => br_netfilter_hooks.c} |    0
 2 files changed, 1 insertion(+)
 rename net/bridge/{br_netfilter.c => br_netfilter_hooks.c} (100%)

diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index fd7ee03..c52577a 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -12,6 +12,7 @@ bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
 
 bridge-$(subst m,y,$(CONFIG_BRIDGE_NETFILTER)) += br_nf_core.o
 
+br_netfilter-y := br_netfilter_hooks.o
 obj-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
 
 bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter_hooks.c
similarity index 100%
rename from net/bridge/br_netfilter.c
rename to net/bridge/br_netfilter_hooks.c
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
