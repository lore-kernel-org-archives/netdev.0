From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/4] net: sched: remove unused tc_should_offload helper
Date: Wed,  1 Nov 2017 11:47:38 +0100
Message-ID: <20171101104741.2216-2-jiri@resnulli.us>
References: <20171101104741.2216-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:54688 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751603AbdKAKro (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 06:47:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id r68so4062601wmr.3
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 03:47:44 -0700 (PDT)
In-Reply-To: <20171101104741.2216-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

tc_should_offload is no longer used, remove it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 37c5ef7..108dcdd 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -623,13 +623,6 @@ static inline bool tc_skip_hw(u32 flags)
 	return (flags & TCA_CLS_FLAGS_SKIP_HW) ? true : false;
 }
 
-static inline bool tc_should_offload(const struct net_device *dev, u32 flags)
-{
-	if (tc_skip_hw(flags))
-		return false;
-	return tc_can_offload(dev);
-}
-
 static inline bool tc_skip_sw(u32 flags)
 {
 	return (flags & TCA_CLS_FLAGS_SKIP_SW) ? true : false;
-- 
2.9.5
