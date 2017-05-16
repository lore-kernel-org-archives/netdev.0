From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/12] mlxsw: Preparations for restructuring
Date: Tue, 16 May 2017 19:38:23 +0200
Message-ID: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34536 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdEPRii (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:38:38 -0400
Received: by mail-wr0-f193.google.com with SMTP id 6so14928235wrb.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:38:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset doesn't introduce any functional changes and merely meant
to make the code base more receptive for upcoming restructuring.

The first six patches mainly shuffle code in order to reduce the scope of
structs that shouldn't be defined in the main driver header. Most of them
will be later expanded, so it makes sense to correctly place them now.

The last patches mostly simplify bridge-related functions, so that they
could be more easily modified later on.

Ido Schimmel (12):
  mlxsw: spectrum_buffer: Reduce scope of shared buffer struct
  mlxsw: spectrum_router: Reduce scope of router struct
  mlxsw: spectrum_switchdev: Reduce scope of bridge struct
  mlxsw: spectrum_router: Move RIFs array to its rightful place
  mlxsw: spectrum_router: Move FIB notification block to router struct
  mlxsw: spectrum_router: Initialize RIFs in a separate function
  mlxsw: spectrum_switchdev: Remove redundant check
  mlxsw: spectrum_switchdev: Don't batch VLAN operations
  mlxsw: spectrum_switchdev: Don't batch STP operations
  mlxsw: spectrum_switchdev: Don't batch learning operations
  mlxsw: spectrum: Move PVID code to appropriate place
  mlxsw: spectrum: Default ports to non-virtual mode

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 118 +++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 131 +------
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c |  73 +++-
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   |  17 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 289 +++++++++-----
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |   2 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 415 ++++++++-------------
 7 files changed, 529 insertions(+), 516 deletions(-)

-- 
2.9.3
