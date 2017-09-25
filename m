From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/10] mlxsw: Add router adjacency dpipe table
Date: Mon, 25 Sep 2017 10:32:20 +0200
Message-ID: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35587 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbdIYIcc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:32 -0400
Received: by mail-wm0-f68.google.com with SMTP id e64so6501470wmi.2
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi says:

This patchset adds router adjacency dpipe table support. This will provide
the ability to observe the hardware offloaded IPv4/6 nexthops.

Arkadi Sharshevsky (10):
  mlxsw: spectrum_dpipe: Fix indentation in header description
  mlxsw: Add fields for mlxsw's meta header for adjacency table
  mlxsw: spectrum_router: Keep nexthops in a linked list
  mlxsw: spectrum_router: Use helper to check for last neighbor
  mlxsw: spectrum_router: Add helpers for nexthop access
  mlxsw: spectrum_dpipe: Add initial support for the router adjacency
    table
  mlxsw: reg: Add support for counters on RATR
  mlxsw: spectrum: Add support for setting counters on nexthops
  mlxsw: spectrum_dpipe: Add support for adjacency table dump
  mlxsw: spectrum_dpipe: Add support for controlling nexthop counters

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  44 ++-
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 397 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.h   |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 134 ++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  20 ++
 5 files changed, 572 insertions(+), 24 deletions(-)

-- 
2.9.5
