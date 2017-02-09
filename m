From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/2] net/devlink: Add E-Switch encapsulation control
Date: Thu,  9 Feb 2017 18:23:16 +0200
Message-ID: <1486657398-6298-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47976 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751818AbdBIQYc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 11:24:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from:  Roi Dayan <roid@mellanox.com>

Add an e-switch global knob to enable/disable HW support for applying
encapsulation/decapsulation to VF traffic as part of SRIOV e-switch 
offloading which is controlled with devlink. Support that in mlx5.

Dave, the series is rebased over the cleanup series Jiri sent earlier today [1]

Or.

[1] http://marc.info/?l=linux-netdev&m=148665219924363&w=2

Roi Dayan (2):
  net/devlink: Add E-Switch encapsulation control
  net/mlx5: E-Switch, Add control for encapsulation

 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  3 ++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 41 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  2 ++
 include/net/devlink.h                              |  2 ++
 include/uapi/linux/devlink.h                       |  1 +
 net/core/devlink.c                                 | 22 ++++++++++++
 7 files changed, 70 insertions(+), 2 deletions(-)

-- 
2.5.5
