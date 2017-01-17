From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/3] ethtool fix
Date: Tue, 17 Jan 2017 19:19:16 +0200
Message-ID: <1484673559-21687-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58787 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751186AbdAQRT5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:19:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset from Eran contains a fix to ethtool set_channels, where the call
to get_channels with an uninitialized parameter might result in garbage fields.
It also contains two followup changes in our mlx4/mlx5 Eth drivers.

Series generated against net commit:
0faa9cb5b383 net sched actions: fix refcnt when GETing of action after bind

Thanks,
Tariq.

Eran Ben Elisha (3):
  net: ethtool: Initialize buffer when querying device channel settings
  net/mlx4_en: Remove unnecessary checks when setting num channels
  net/mlx5e: Remove unnecessary checks when setting num channels

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c      |  7 +------
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 10 ----------
 net/core/ethtool.c                                   |  2 +-
 3 files changed, 2 insertions(+), 17 deletions(-)

-- 
1.8.3.1
