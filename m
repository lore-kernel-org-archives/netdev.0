From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/4] net: sched: block callbacks follow-up
Date: Wed,  1 Nov 2017 11:47:37 +0100
Message-ID: <20171101104741.2216-1-jiri@resnulli.us>
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
Received: from mail-wm0-f67.google.com ([74.125.82.67]:54683 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdKAKro (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 06:47:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id r68so4062535wmr.3
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 03:47:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset does a bit of cleanup of leftovers after block callbacks
patchset. The main part is patch 2, which restores the original handling
of tc offload feature flag.

---
v1->v2:
- rebased on top of current net-next (bnxt changes)

Jiri Pirko (4):
  net: sched: remove unused tc_should_offload helper
  net: sched: move the can_offload check from binding phase to rule
    insertion phase
  net: sched: remove tc_can_offload check from egdev call
  net: sched: remove ndo_setup_tc check from tc_can_offload

 drivers/net/ethernet/broadcom/bnxt/bnxt.c           |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c       |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c    |  3 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c      |  3 +++
 drivers/net/ethernet/netronome/nfp/bpf/main.c       |  3 +++
 drivers/net/ethernet/netronome/nfp/flower/offload.c |  3 +++
 include/net/pkt_cls.h                               | 13 +------------
 net/dsa/slave.c                                     |  3 +++
 net/sched/cls_api.c                                 |  4 ++--
 12 files changed, 29 insertions(+), 16 deletions(-)

-- 
2.9.5
