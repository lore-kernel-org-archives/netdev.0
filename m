From: David Miller <davem@davemloft.net>
Subject: [PATCH 19/25] net: Add flowi6_* member helper macros.
Date: Sat, 12 Mar 2011 15:29:41 -0800 (PST)
Message-ID: <20110312.152941.116379298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755582Ab1CLX3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:29:04 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E0CAA24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:29:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 3e4630e..8d5b402 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -65,6 +65,14 @@ struct flowi4 {
 
 struct flowi6 {
 	struct flowi_common	__fl_common;
+#define flowi6_oif		__fl_common.flowic_oif
+#define flowi6_iif		__fl_common.flowic_iif
+#define flowi6_mark		__fl_common.flowic_mark
+#define flowi6_tos		__fl_common.flowic_tos
+#define flowi6_scope		__fl_common.flowic_scope
+#define flowi6_proto		__fl_common.flowic_proto
+#define flowi6_flags		__fl_common.flowic_flags
+#define flowi6_secid		__fl_common.flowic_secid
 	struct in6_addr		daddr;
 	struct in6_addr		saddr;
 	__be32			flowlabel;
-- 
1.7.4.1

