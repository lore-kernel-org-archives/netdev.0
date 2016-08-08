From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 0/5] net_sched: tc action fixes and updates
Date: Mon,  8 Aug 2016 13:46:44 -0700
Message-ID: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34960 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbcHHUq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 16:46:58 -0400
Received: by mail-pa0-f68.google.com with SMTP id cf3so24467826pad.2
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 13:46:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes several regressions caused by the previous
code refactor. Thanks to Jamal for catching them!

Note, patch 3/5 and 4/5 are not strictly necessary, I just
want to carry them together.

Cong Wang (5):
  net_sched: remove the leftover cleanup_a()
  net_sched: remove an unnecessary list_del()
  net_sched: fix a typo in tc_for_each_action()
  net_sched: move tc offload macros to pkt_cls.h
  net_sched: convert tcf_exts from list to flex_array

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c  |  4 +-
 include/net/act_api.h                           | 16 -------
 include/net/pkt_cls.h                           | 46 +++++++++++++++++---
 net/sched/act_api.c                             | 23 ++--------
 net/sched/cls_api.c                             | 57 ++++++++++++++++++-------
 7 files changed, 101 insertions(+), 61 deletions(-)

-- 
2.1.0
