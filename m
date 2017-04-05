From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/sched: Removed unused vlan actions definition
Date: Wed,  5 Apr 2017 19:09:25 +0300
Message-ID: <1491408565-21606-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58826 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754870AbdDEQJm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 12:09:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c7e2b9689ef "sched: introduce vlan action" added both the
UAPI values for the vlan actions (TCA_VLAN_ACT_) and these two
in-kernel ones which are not used, remove them.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/tc_act/tc_vlan.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
index 9690c04..c2090df 100644
--- a/include/net/tc_act/tc_vlan.h
+++ b/include/net/tc_act/tc_vlan.h
@@ -13,9 +13,6 @@
 #include <net/act_api.h>
 #include <linux/tc_act/tc_vlan.h>
 
-#define VLAN_F_POP		0x1
-#define VLAN_F_PUSH		0x2
-
 struct tcf_vlan {
 	struct tc_action	common;
 	int			tcfv_action;
-- 
2.3.7
