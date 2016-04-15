From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] devlink: fix sb register stub in case devlink is disabled
Date: Fri, 15 Apr 2016 09:17:08 +0200
Message-ID: <1460704628-3662-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, fengguang.wu@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36682 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbcDOHRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:17:11 -0400
Received: by mail-wm0-f50.google.com with SMTP id v188so18170610wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:17:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: bf7974710a40 ("devlink: add shared buffer configuration")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index be64218..1d45b61 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -184,7 +184,9 @@ static inline void devlink_port_split_set(struct devlink_port *devlink_port,
 static inline int devlink_sb_register(struct devlink *devlink,
 				      unsigned int sb_index, u32 size,
 				      u16 ingress_pools_count,
-				      u16 egress_pools_count, u16 tc_count)
+				      u16 egress_pools_count,
+				      u16 ingress_tc_count,
+				      u16 egress_tc_count)
 {
 	return 0;
 }
-- 
2.5.5
