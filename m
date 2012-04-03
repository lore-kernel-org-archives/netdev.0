From: pablo@netfilter.org
Subject: [PATCH 2/3] netfilter: ipset: avoid use of kernel-only types
Date: Tue,  3 Apr 2012 12:13:20 +0200
Message-ID: <1333448001-2507-3-git-send-email-pablo@netfilter.org>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33513 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753670Ab2DCKNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 06:13:51 -0400
In-Reply-To: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

When using the xt_set.h header in userspace, one will get these gcc
reports:

ipset/ip_set.h:184:1: error: unknown type name "u16"
In file included from libxt_SET.c:21:0:
netfilter/xt_set.h:61:2: error: unknown type name "u32"
netfilter/xt_set.h:62:2: error: unknown type name "u32"

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/xt_set.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/xt_set.h b/include/linux/netfilter/xt_set.h
index c0405ac..e3a9978 100644
--- a/include/linux/netfilter/xt_set.h
+++ b/include/linux/netfilter/xt_set.h
@@ -58,8 +58,8 @@ struct xt_set_info_target_v1 {
 struct xt_set_info_target_v2 {
 	struct xt_set_info add_set;
 	struct xt_set_info del_set;
-	u32 flags;
-	u32 timeout;
+	__u32 flags;
+	__u32 timeout;
 };
 
 #endif /*_XT_SET_H*/
-- 
1.7.2.5
