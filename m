From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/4] net: sched: remove unused tc_should_offload helper
Date: Wed, 25 Oct 2017 16:34:57 +0200
Message-ID: <20171025143500.28973-2-jiri@resnulli.us>
References: <20171025143500.28973-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:55975 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932155AbdJYOfC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:35:02 -0400
Received: by mail-wr0-f196.google.com with SMTP id l8so181882wre.12
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:35:02 -0700 (PDT)
In-Reply-To: <20171025143500.28973-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

tc_should_offload is no longer used, remove it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 04caa24..0d24d22 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -621,13 +621,6 @@ static inline bool tc_skip_hw(u32 flags)
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
