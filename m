From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] act_connmark: Add missing dependency on NF_CONNTRACK_MARK
Date: Tue, 20 Jan 2015 13:44:25 +0100
Message-ID: <eb5e12e8fec691cb08e663f2f8ed183ac92e5a1f.1421757793.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Felix Fietkau <nbd@openwrt.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35689 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbbATMoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 07:44:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending on NETFILTER is not sufficient to ensure the presence of the
'mark' field in nf_conn, also needs to depend on NF_CONNTRACK_MARK.

Fixes: 22a5dc ("net: sched: Introduce connmark action")
Cc: Felix Fietkau <nbd@openwrt.org>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/sched/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 475e35e..7a57f66 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -713,6 +713,7 @@ config NET_ACT_BPF
 config NET_ACT_CONNMARK
         tristate "Netfilter Connection Mark Retriever"
         depends on NET_CLS_ACT && NETFILTER && IP_NF_IPTABLES
+        depends on NF_CONNTRACK_MARK
         ---help---
 	  Say Y here to allow retrieving of conn mark
 
-- 
1.9.3
