From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 02/13] flow_dissector: Add enums for encapsulation keys
Date: Mon,  7 Nov 2016 15:14:37 +0200
Message-ID: <1478524488-1377-3-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39581 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753382AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

New encapsulation keys were added to the flower classifier, which allow
classification according to outer (encapsulation) headers attributes
such as key and IP addresses.
In order to expose those attributes outside flower, add
corresponding enums in the flow dissector.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/flow_dissector.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index d953492..4e7cf38a 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -128,6 +128,10 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_tags */
 	FLOW_DISSECTOR_KEY_GRE_KEYID, /* struct flow_dissector_key_keyid */
 	FLOW_DISSECTOR_KEY_MPLS_ENTROPY, /* struct flow_dissector_key_keyid */
+	FLOW_DISSECTOR_KEY_ENC_KEYID, /* struct flow_dissector_key_keyid */
+	FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS, /* struct flow_dissector_key_ipv4_addrs */
+	FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
+	FLOW_DISSECTOR_KEY_ENC_CONTROL, /* struct flow_dissector_key_control */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
-- 
2.7.4
