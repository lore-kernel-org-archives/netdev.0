From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/3] net: vlan: fix up vlan_proto_idx() for CONFIG_BUG=n
Date: Sun, 21 Apr 2013 12:09:32 +0200
Message-ID: <1366538974-4589-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62309 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab3DUKJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 06:09:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing return statement for CONFIG_BUG=n.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/8021q/vlan.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index abc9cb6..ba5983f 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -121,6 +121,7 @@ static inline unsigned int vlan_proto_idx(__be16 proto)
 		return VLAN_PROTO_8021AD;
 	default:
 		BUG();
+		return 0;
 	}
 }
 
-- 
1.8.1.4
