From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] mlxsw: Query resources from firmware
Date: Fri, 24 Mar 2017 08:02:46 +0100
Message-ID: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35223 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752021AbdCXHJr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 03:09:47 -0400
Received: by mail-wr0-f193.google.com with SMTP id u108so735358wrb.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 00:09:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

Some parts of the driver already use the resource query mechanism, but
in other parts we still rely on hard coded values that may change over
time.

This patchset removes most of these remaining values and queries them
from the firmware instead.

Ido Schimmel (5):
  mlxsw: spectrum_router: Query number of LPM trees from firmware
  mlxsw: Query maximum number of ports from firmware
  mlxsw: spectrum_buffers: Query shared buffer size from firmware
  mlxsw: spectrum: Refactor port buffer configuration
  mlxsw: spectrum: Query cell size from firmware

 drivers/net/ethernet/mellanox/mlxsw/core.c         |  46 ++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   2 +
 drivers/net/ethernet/mellanox/mlxsw/port.h         |  10 +-
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |   4 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 107 +++++++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  52 +++---
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 187 +++++++++++++--------
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  51 +++++-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |   7 +-
 10 files changed, 314 insertions(+), 154 deletions(-)

-- 
2.7.4
