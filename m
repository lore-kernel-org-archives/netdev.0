From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/3] mlxsw: Router fixes
Date: Fri, 23 Dec 2016 09:32:47 +0100
Message-ID: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33548 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754763AbcLWIcx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 03:32:53 -0500
Received: by mail-wj0-f193.google.com with SMTP id kp2so39197123wjc.0
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 00:32:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

First two patches ensure we remove from the device's table neighbours
that are considered to be dead by the neighbour core.

The last patch removes nexthop groups from the device when they are no
longer valid.

Ido Schimmel (3):
  neigh: Send netevent after marking neigh as dead
  mlxsw: spectrum_router: Don't reflect dead neighs
  mlxsw: spectrum_router: Correctly remove nexthop groups

 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 13 +++++++++----
 net/core/neighbour.c                                  |  1 +
 2 files changed, 10 insertions(+), 4 deletions(-)

-- 
2.7.4
