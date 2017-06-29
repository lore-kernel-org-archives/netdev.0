From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/2] mlx4_en dynamic TC tx queues
Date: Thu, 29 Jun 2017 14:07:55 +0300
Message-ID: <1498734477-26111-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Inbar Karmy <inbark@mellanox.com>,
        Tarick Bedeir <tarick@google.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55781 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751725AbdF2LIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 07:08:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset from Inbar aligns the number of TX queues
to the actual need, according to the TC configuration.

Series generated against net-next commit:
2ee87db3a287 Merge branch 'nfp-get_phys_port_name-for-representors-and-SR-IOV-reorder'

Thanks,
Tariq.


Inbar Karmy (2):
  net/mlx4_en: Add dynamic variable to hold the number of user
    priorities (UP)
  net/mlx4_en: Do not allocate redundant TX queues when TC is disabled

 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c    |  6 +--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c   | 17 ++++---
 drivers/net/ethernet/mellanox/mlx4/en_main.c      |  4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    | 60 ++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |  3 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |  6 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |  9 ++--
 7 files changed, 79 insertions(+), 26 deletions(-)

-- 
1.8.3.1
