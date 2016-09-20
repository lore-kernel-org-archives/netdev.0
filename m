From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 0/4] mlx4 misc cleanups and improvements
Date: Tue, 20 Sep 2016 14:39:38 +0300
Message-ID: <1474371582-998-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36737 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750775AbcITLlW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 07:41:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains some cleanups and improvements from the team
to the mlx4 Eth and core drivers.

Series generated against net-next commit:
5a7a5555a362 'net sched: stylistic cleanups'

Thanks,
Tariq.

V2:
* dropped patch 5, will be submitted separately to 'net'.

Jack Morgenstein (1):
  net/mlx4_core: Fix deadlock when switching between polling and event
    fw commands

Kamal Heib (1):
  net/mlx4_en: Fix wrong indentation

Leon Romanovsky (1):
  net/mlx4_core: Use RCU to perform radix tree lookup for SRQ

Tariq Toukan (1):
  net/mlx4_en: Add branch prediction hints in RX data-path

 drivers/net/ethernet/mellanox/mlx4/cmd.c   | 23 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 28 +++++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |  2 ++
 drivers/net/ethernet/mellanox/mlx4/srq.c   | 14 +++++---------
 4 files changed, 39 insertions(+), 28 deletions(-)

-- 
1.8.3.1
