From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2 0/5] net_sched: tc action fixes and updates
Date: Wed, 10 Aug 2016 13:16:10 -0700
Message-ID: <1470860175-10903-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34645 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932915AbcHJUQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 16:16:32 -0400
Received: by mail-pf0-f193.google.com with SMTP id g202so3377116pfb.1
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 13:16:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes a few regressions caused by the previous
code refactor. Thanks to Jamal for catching them!

Note, patch 3/5 and 4/5 are not strictly necessary for this patchset,
I just want to carry them together.

---
v2: replace flex_array with regular dynamic array
    keep tcf_action_stats_update() in act_api.h
    fix macro typos found by Amir

Cong Wang (5):
  net_sched: remove the leftover cleanup_a()
  net_sched: remove an unnecessary list_del()
  net_sched: fix a typo in tc_for_each_action()
  net_sched: move tc offload macros to pkt_cls.h
  net_sched: convert tcf_exts from list to pointer array

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c  |  4 +-
 include/net/act_api.h                           | 19 ++-------
 include/net/pkt_cls.h                           | 43 ++++++++++++++++++---
 net/sched/act_api.c                             | 23 ++---------
 net/sched/cls_api.c                             | 51 +++++++++++++++++--------
 7 files changed, 95 insertions(+), 61 deletions(-)

-- 
2.1.0
