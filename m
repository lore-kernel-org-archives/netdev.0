From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/3] mlx5 fixes to 4.8-rc6
Date: Sun, 18 Sep 2016 18:20:26 +0300
Message-ID: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56226 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936458AbcIRPUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:20:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series series has a fix from Roi to memory corruption bug in 
the bulk flow counters code and two late and hopefully last fixes 
from me to the new eswitch offloads code.

Series done over net commit 37dd348 "bna: fix crash in bnad_get_strings()"

Or.

Or Gerlitz (2):
  net/mlx5: E-Switch, Fix error flow in the SRIOV e-switch init code
  net/mlx5: E-Switch, Handle mode change failures

Roi Dayan (1):
  net/mlx5: Fix flow counter bulk command out mailbox allocation

 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c    |  1 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c   | 20 ++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c     |  4 ++--
 3 files changed, 17 insertions(+), 8 deletions(-)

-- 
2.3.7
