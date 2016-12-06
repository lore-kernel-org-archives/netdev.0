From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/3] net/flow_dissector: Enable matching on flags for TC filter consumers
Date: Tue,  6 Dec 2016 14:32:57 +0200
Message-ID: <1481027579-23195-2-git-send-email-ogerlitz@mellanox.com>
References: <1481027579-23195-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Tom Herbert <tom@herbertland.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41022 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752090AbcLFMdK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 07:33:10 -0500
In-Reply-To: <1481027579-23195-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a pre-step to allow TC classifiers that makes use of the
flow-dissector (e.g Flower) to match on flow-dissector flags which
are located in the control struct.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/net/flow_dissector.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index c4f3166..a679e6c 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -154,8 +154,8 @@ struct flow_dissector {
 };
 
 struct flow_keys {
+#define FLOW_KEYS_HASH_START_FIELD control
 	struct flow_dissector_key_control control;
-#define FLOW_KEYS_HASH_START_FIELD basic
 	struct flow_dissector_key_basic basic;
 	struct flow_dissector_key_tags tags;
 	struct flow_dissector_key_vlan vlan;
-- 
2.3.7
Cc: Tom Herbert <tom@herbertland.com>
