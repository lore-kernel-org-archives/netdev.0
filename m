From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: [PATCH net-next 0/4] act_mirred: Ingress actions support
Date: Thu, 22 Sep 2016 16:21:48 +0300
Message-ID: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37173 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933341AbcIVNWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 09:22:32 -0400
Received: by mail-wm0-f45.google.com with SMTP id b130so148547582wmc.0
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 06:22:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements action mirred 'ingress' actions
TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.

This allows attaching filters whose target is to hand matching skbs into
the rx processing of a specified device.

Shmulik Ladkani (4):
  net/sched: act_mirred: Rename tcfm_ok_push to tcfm_mac_header_xmit
  net/sched: act_mirred: Refactor detection whether dev needs xmit at
    mac header
  net/sched: tc_mirred: Rename public predicates
    'is_tcf_mirred_redirect' and 'is_tcf_mirred_mirror'
  net/sched: act_mirred: Implement ingress actions

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  4 +-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  2 +-
 include/net/tc_act/tc_mirred.h                     |  6 +-
 net/sched/act_mirred.c                             | 80 ++++++++++++++++------
 7 files changed, 69 insertions(+), 29 deletions(-)

-- 
1.9.1
