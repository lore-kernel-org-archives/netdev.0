From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 30/34] net: sched: remove unused classid field from tc_cls_common_offload
Date: Thu, 12 Oct 2017 19:18:19 +0200
Message-ID: <20171012171823.1431-31-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:47987 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755797AbdJLRSx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id t69so15072504wmt.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:52 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

It is no longer used by the drivers, so remove it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 2e73832..1c8ef4f 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -572,7 +572,6 @@ struct tc_cls_common_offload {
 	u32 chain_index;
 	__be16 protocol;
 	u32 prio;
-	u32 classid;
 };
 
 static inline void
@@ -582,7 +581,6 @@ tc_cls_common_offload_init(struct tc_cls_common_offload *cls_common,
 	cls_common->chain_index = tp->chain->index;
 	cls_common->protocol = tp->protocol;
 	cls_common->prio = tp->prio;
-	cls_common->classid = tp->classid;
 }
 
 struct tc_cls_u32_knode {
-- 
2.9.5
