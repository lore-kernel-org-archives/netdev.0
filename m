From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 19/20] net: sched: remove unused classid field from tc_cls_common_offload
Date: Tue, 17 Oct 2017 22:06:14 +0200
Message-ID: <20171017200615.4530-20-jiri@resnulli.us>
References: <20171017200615.4530-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:47475 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764073AbdJQUGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:33 -0400
Received: by mail-wr0-f193.google.com with SMTP id y39so2907025wrd.4
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:33 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

It is no longer used by the drivers, so remove it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index fcca5a9..04caa24 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -561,7 +561,6 @@ struct tc_cls_common_offload {
 	u32 chain_index;
 	__be16 protocol;
 	u32 prio;
-	u32 classid;
 };
 
 static inline void
@@ -571,7 +570,6 @@ tc_cls_common_offload_init(struct tc_cls_common_offload *cls_common,
 	cls_common->chain_index = tp->chain->index;
 	cls_common->protocol = tp->protocol;
 	cls_common->prio = tp->prio;
-	cls_common->classid = tp->classid;
 }
 
 struct tc_cls_u32_knode {
-- 
2.9.5
