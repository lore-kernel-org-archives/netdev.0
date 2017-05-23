From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/5] add tcp flags match support to flower and offload it
Date: Tue, 23 May 2017 18:40:43 +0200
Message-ID: <20170523164048.16514-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34107 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759850AbdEWQkv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:40:51 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so40691252wmf.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 09:40:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patch adds support to dissect tcp flags, match on them using
flower classifier and offload such rules to mlxsw Spectrum devices.

---
v1->v2:
- removed no longer relevant comment from patch 1 as suggested by Or
- sent correct patches this time

Jiri Pirko (5):
  net: flow_dissector: add support for dissection of tcp flags
  net/sched: flower: add support for matching on tcp flags
  mlxsw: acl: Add tcp flags acl element
  mlxsw: spectrum: Add acl block containing tcp flags for ipv4
  mlxsw: spectrum_flower: Add support for tcp flags

 .../ethernet/mellanox/mlxsw/core_acl_flex_keys.h   |  2 ++
 .../mellanox/mlxsw/spectrum_acl_flex_keys.h        |  6 +++++
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    |  1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 30 ++++++++++++++++++++++
 include/net/flow_dissector.h                       |  9 +++++++
 include/uapi/linux/pkt_cls.h                       |  3 +++
 net/core/flow_dissector.c                          | 29 +++++++++++++++++++++
 net/sched/cls_flower.c                             | 13 +++++++++-
 8 files changed, 92 insertions(+), 1 deletion(-)

-- 
2.9.3
