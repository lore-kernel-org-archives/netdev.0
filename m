From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] rtnetlink: Add rtnexthop offload flag to compare mask
Date: Tue, 18 Oct 2016 18:59:34 +0200
Message-ID: <1476809974-14707-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33912 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933242AbcJRQ7h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 12:59:37 -0400
Received: by mail-wm0-f67.google.com with SMTP id d199so340809wmd.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 09:59:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The offload flag is a status flag and should not be used by
FIB semantics for comparison.

Fixes: 37ed9493699c ("rtnetlink: add RTNH_F_EXTERNAL flag for fib offload")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
Please queue-up to stable as well. Thanks.
---
 include/uapi/linux/rtnetlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 262f037..5a78be5 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -350,7 +350,7 @@ struct rtnexthop {
 #define RTNH_F_OFFLOAD		8	/* offloaded route */
 #define RTNH_F_LINKDOWN		16	/* carrier-down on nexthop */
 
-#define RTNH_COMPARE_MASK	(RTNH_F_DEAD | RTNH_F_LINKDOWN)
+#define RTNH_COMPARE_MASK	(RTNH_F_DEAD | RTNH_F_LINKDOWN | RTNH_F_OFFLOAD)
 
 /* Macros to handle hexthops */
 
-- 
2.5.5
