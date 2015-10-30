From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/2] bridge: vlan: Use correct flag name in comment
Date: Fri, 30 Oct 2015 17:46:20 +0100
Message-ID: <1446223580-1464-3-git-send-email-razor@blackwall.org>
References: <1446223580-1464-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	nikolay@cumulusnetworks.com, idosch@mellanox.com,
	roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33807 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbbJ3QyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 12:54:20 -0400
Received: by wmff134 with SMTP id f134so16242067wmf.1
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 09:54:19 -0700 (PDT)
In-Reply-To: <1446223580-1464-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The flag used to indicate if a VLAN should be used for filtering - as
opposed to context only - on the bridge itself (e.g. br0) is called
'brentry' and not 'brvlan'.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_vlan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 1054696323d7..dc1a2da55d09 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -180,11 +180,11 @@ static void br_vlan_put_master(struct net_bridge_vlan *masterv)
  * devices. There are four possible calls to this function in terms of the
  * vlan entry type:
  * 1. vlan is being added on a port (no master flags, global entry exists)
- * 2. vlan is being added on a bridge (both master and brvlan flags)
+ * 2. vlan is being added on a bridge (both master and brentry flags)
  * 3. vlan is being added on a port, but a global entry didn't exist which
- *    is being created right now (master flag set, brvlan flag unset), the
+ *    is being created right now (master flag set, brentry flag unset), the
  *    global entry is used for global per-vlan features, but not for filtering
- * 4. same as 3 but with both master and brvlan flags set so the entry
+ * 4. same as 3 but with both master and brentry flags set so the entry
  *    will be used for filtering in both the port and the bridge
  */
 static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
-- 
2.4.3
