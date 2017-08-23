From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] mlxsw: spectrum: Introduce multichain TC offload
Date: Wed, 23 Aug 2017 10:06:52 +0200
Message-ID: <20170823080652.14847-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38820 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753386AbdHWIGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:06:55 -0400
Received: by mail-wr0-f196.google.com with SMTP id k10so582269wre.5
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 01:06:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset introduces offloading of rules added to chain with
non-zero index, which was previously forbidden. Also, goto_chain
termination action is offloaded allowing to jump to processing
of desired chain.

Jiri Pirko (5):
  mlxsw: spectrum: Offload multichain TC rules
  net: sched: add couple of goto_chain helpers
  mlxsw: spectrum_acl: Allow to get group_id value for a ruleset
  mlxsw: spectrum_acl: Provide helper to lookup ruleset
  mlxsw: spectrum_flower: Offload goto_chain termination action

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  3 -
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 10 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 78 +++++++++++++++++-----
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    | 15 +++++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 28 ++++++--
 include/net/tc_act/tc_gact.h                       | 20 ++++--
 6 files changed, 124 insertions(+), 30 deletions(-)

-- 
2.9.3
