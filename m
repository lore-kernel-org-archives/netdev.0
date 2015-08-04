From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/18] netfilter: bridge: do not initialize statics to 0 or NULL
Date: Tue,  4 Aug 2015 12:02:47 +0200
Message-ID: <1438682568-8346-18-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56108 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933158AbbHDJ5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:44 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

Fix checkpatch.pl "ERROR: do not initialise statics to 0 or NULL" for
all statics explicitly initialized to 0.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter_hooks.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index ec51c2b..0a6f095 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -49,9 +49,9 @@ static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables __read_mostly = 1;
 static int brnf_call_ip6tables __read_mostly = 1;
 static int brnf_call_arptables __read_mostly = 1;
-static int brnf_filter_vlan_tagged __read_mostly = 0;
-static int brnf_filter_pppoe_tagged __read_mostly = 0;
-static int brnf_pass_vlan_indev __read_mostly = 0;
+static int brnf_filter_vlan_tagged __read_mostly;
+static int brnf_filter_pppoe_tagged __read_mostly;
+static int brnf_pass_vlan_indev __read_mostly;
 #else
 #define brnf_call_iptables 1
 #define brnf_call_ip6tables 1
-- 
1.7.10.4
