From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/7] netfilter: nf_tables: nat expression must select CONFIG_NF_NAT
Date: Tue,  2 Sep 2014 12:14:00 +0200
Message-ID: <1409652844-10289-4-git-send-email-pablo@netfilter.org>
References: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This enables the netfilter NAT engine in first place, otherwise
you cannot ever select the nf_tables nat expression if iptables
is not selected.

Reported-by: Matteo Croce <technoboy85@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ad751fe..05eb177 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -499,7 +499,7 @@ config NFT_LIMIT
 config NFT_NAT
 	depends on NF_TABLES
 	depends on NF_CONNTRACK
-	depends on NF_NAT
+	select NF_NAT
 	tristate "Netfilter nf_tables nat module"
 	help
 	  This option adds the "nat" expression that you can use to perform
-- 
1.7.10.4

