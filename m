From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] mlxsw: Driver update
Date: Fri, 21 Oct 2016 16:07:17 +0200
Message-ID: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34955 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755689AbcJUOH3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:07:29 -0400
Received: by mail-lf0-f49.google.com with SMTP id l131so140173949lfl.2
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:07:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Mostly cosmetics and small resource values management rewrite.

Jiri Pirko (6):
  mlxsw: item: Make struct mlxsw_item args const
  mlxsw: item: Make char *buf arg constant for getters
  mlxsw: reg: Use helper macro to define registers
  mlxsw: reg: Generare register names automatically
  mlxsw: cmd: Push resource query defines to cmd.h
  mlxsw: Convert resources into array

 drivers/net/ethernet/mellanox/mlxsw/cmd.h          |   5 +
 drivers/net/ethernet/mellanox/mlxsw/core.c         |  32 +-
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  44 +-
 drivers/net/ethernet/mellanox/mlxsw/item.h         |  50 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c          | 142 ++----
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 502 ++++++---------------
 drivers/net/ethernet/mellanox/mlxsw/resources.h    | 121 +++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  42 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   5 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  39 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   7 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |   2 +-
 12 files changed, 405 insertions(+), 586 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/resources.h

-- 
2.5.5
