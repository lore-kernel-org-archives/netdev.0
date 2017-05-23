From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] add tcp flags match support to flower and offload it
Date: Tue, 23 May 2017 16:31:05 +0200
Message-ID: <20170523143110.5006-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38057 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933794AbdEWObR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:31:17 -0400
Received: by mail-wm0-f51.google.com with SMTP id e127so31127182wmg.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 07:31:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patch adds support to dissect tcp flags, match on them using
flower classifier and offload such rules to mlxsw Spectrum devices.

Jiri Pirko (5):
  net: sched: cls_api: make reclassify return all the way back to the
    original tp
  net: flow_dissector: add support for dissection of tcp flags
  net/sched: flower: add support for matching on tcp flags
  mlxsw: acl: Add tcp flags acl element
  mlxsw: spectrum: Add acl block containing tcp flags for ipv4

 .../ethernet/mellanox/mlxsw/core_acl_flex_keys.h   |  2 ++
 .../mellanox/mlxsw/spectrum_acl_flex_keys.h        |  6 +++++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  1 +
 include/net/flow_dissector.h                       |  9 +++++++
 include/uapi/linux/pkt_cls.h                       |  3 +++
 net/core/flow_dissector.c                          | 31 ++++++++++++++++++++++
 net/sched/cls_api.c                                |  8 +++---
 net/sched/cls_flower.c                             | 13 ++++++++-
 8 files changed, 69 insertions(+), 4 deletions(-)

-- 
2.9.3
