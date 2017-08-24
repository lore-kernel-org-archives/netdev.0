From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/12] mlxsw: Add IPv4 host dpipe table
Date: Thu, 24 Aug 2017 08:39:58 +0200
Message-ID: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34900 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751937AbdHXGkP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:15 -0400
Received: by mail-wm0-f67.google.com with SMTP id x79so1699143wma.2
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi says:

This patchset adds IPv4 host dpipe table support. This will provide the
ability to observe the hardware offloaded IPv4 neighbors.

Arkadi Sharshevsky (12):
  devlink: Add Ethernet header for dpipe
  devlink: Add IPv4 header for dpipe
  mlxsw: spectrum_dpipe: Fix erif table op name space
  devlink: Add support for dynamic table size
  devlink: Move dpipe entry clear function into devlink
  mlxsw: spectrum_router: Add helpers for neighbor access
  mlxsw: spectrum_dpipe: Fix label name
  mlxsw: spectrum_dpipe: Add IPv4 host table initial support
  mlxsw: reg: Make flow counter set type enum to be shared
  mlxsw: spectrum_router: Add support for setting counters on neighbors
  mlxsw: spectrum_dpipe: Add support for IPv4 host table dump
  mlxsw: spectrum_dpipe: Add support for controlling neighbor counters

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  28 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  10 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 433 +++++++++++++++++++--
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 104 +++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  20 +
 include/net/devlink.h                              |  15 +-
 include/uapi/linux/devlink.h                       |  13 +
 net/core/devlink.c                                 |  68 +++-
 9 files changed, 636 insertions(+), 56 deletions(-)

-- 
2.9.3
