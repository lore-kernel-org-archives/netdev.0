From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/13] mlxsw: Prepare for multicast router offload
Date: Tue, 19 Sep 2017 10:00:07 +0200
Message-ID: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35644 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751227AbdISIAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:23 -0400
Received: by mail-wr0-f193.google.com with SMTP id n64so1712600wrb.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:

This patch-set makes various preparations needed for the multicast router
offloading, which include:
 - Add the needed registers.
 - Add needed ACL actions.
 - Add new traps and trap groups.
 - Exporting needed private structs and enums.

Yotam Gigi (13):
  mlxsw: spectrum: Change init order
  mlxsw: spectrum: Move ACL flexible actions instance to spectrum
  mlxsw: acl: Introduce mcrouter ACL action
  mlxsw: acl: Change trap ACL action to get the trap_id as a parameter
  mlxsw: reg: Rename the flexible action set length field
  mlxsw: reg: Add The Router TCAM Allocation register
  mlxsw: reg: Add the Router Interface Group Version 2 register
  mlxsw: resources: Add multicast ERIF list entries resource
  mlxsw: reg: Add the Router Multicast Forwarding Table Version 2
    register
  mlxsw: reg: Add Router Rules Copy Register
  mlxsw: reg: Configure RIF to forward IPv4 multicast packets by default
  mlxsw: spectrum_router: Export RIF dev access function
  mlxsw: spectrum: Add multicast router traps and trap groups

 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   2 +-
 .../mellanox/mlxsw/core_acl_flex_actions.c         |  75 ++++-
 .../mellanox/mlxsw/core_acl_flex_actions.h         |   5 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 363 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  38 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c |  96 +-----
 .../mellanox/mlxsw/spectrum_acl_flex_actions.c     | 129 ++++++++
 .../mellanox/mlxsw/spectrum_acl_flex_actions.h     |  44 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |   5 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |   1 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |   4 +
 13 files changed, 655 insertions(+), 110 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_actions.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_actions.h

-- 
2.9.5
