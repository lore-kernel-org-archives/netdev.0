From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] mlxsw: Add IPv6 host dpipe table
Date: Wed, 30 Aug 2017 14:02:58 +0200
Message-ID: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35324 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdH3MDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id e204so1553033wma.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi says:

This patchset adds IPv6 host dpipe table support. This will provide the
ability to observe the hardware offloaded IPv6 neighbors.

Arkadi Sharshevsky (8):
  devlink: Add IPv6 header for dpipe
  mlxsw: spectrum_router: Export IPv6 link local address check helper
  mlxsw: spectrum_dpipe: Add IPv6 host table initial support
  mlxsw: spectrum_router: Add IPv6 neighbor access helper
  mlxsw: spectrum_dpipe: Make host entry fill handler more generic
  mlxsw: spectrum_dpipe: Add support for IPv6 host table dump
  mlxsw: spectrum_router: Add support for setting counters on IPv6
    neighbors
  mlxsw: spectrum_dpipe: Add support for controlling IPv6 neighbor
    counters

 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 182 ++++++++++++++++++---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  37 ++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |   3 +
 include/net/devlink.h                              |   1 +
 include/uapi/linux/devlink.h                       |   5 +
 net/core/devlink.c                                 |  17 ++
 7 files changed, 219 insertions(+), 27 deletions(-)

-- 
2.9.3
