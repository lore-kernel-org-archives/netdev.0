From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/9] mlxsw: Replace Hw related const with resource query results
Date: Tue, 20 Sep 2016 11:16:48 +0200
Message-ID: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33016 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbcITJRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:00 -0400
Received: by mail-wm0-f66.google.com with SMTP id w84so2315945wmg.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:16:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Nogah says:

Many of the ASIC's properties can be read from the HW with resources query.
This patchset adds new resources to the resource query and implement
using them, instead of the constants that we currently use.
Those resources are lag, kvd and router related.

Nogah Frankel (9):
  mlxsw: pci: Add lag related resources to resources query
  mlxsw: spectrum: lag resources- use resources data instead of consts
  mlxsw: pci: Add KVD size relate resources
  mlxsw: profile: Add KVD resources to profile config
  mlxsw: pci: Add max virtual routers resource
  mlxsw: spectrum: Implement max virtual routers resource
  mlxsw: pci: Add some miscellaneous resources
  mlxsw: pci: Add max router interface resource
  mlxsw: spectrum: Implement max rif resource

 drivers/net/ethernet/mellanox/mlxsw/core.c         |  26 ++--
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  41 +++++--
 drivers/net/ethernet/mellanox/mlxsw/pci.c          | 135 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  67 ++++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  21 ++--
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  74 +++++++++--
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |   4 -
 8 files changed, 276 insertions(+), 96 deletions(-)

-- 
2.5.5
