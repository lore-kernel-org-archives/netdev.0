From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/4] mlx4 misc fixes
Date: Tue,  1 Aug 2017 16:43:42 +0300
Message-ID: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43056 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751952AbdHANog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 09:44:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains misc bug fixes from the team
to the mlx4 Core and Eth drivers.

Patch 1 by Inbar fixes a wrong ethtool indication for Wake-on-LAN.
The other 3 patches by Jack add a missing capability description,
and fixes the off-by-1 misalignment for the following capabilities
descriptions.

Series generated against net commit:
cc75f8514db6 samples/bpf: fix bpf tunnel cleanup

Thanks,
Tariq.


Inbar Karmy (1):
  net/mlx4_en: Fix wrong indication of Wake-on-LAN (WoL) support

Jack Morgenstein (3):
  net/mlx4_core: Fix sl_to_vl_change bit offset in flags2 dump
  net/mlx4_core: Fix namespace misalignment in QinQ VST support commit
  net/mlx4_core: Fixes missing capability bit in flags2 capability dump

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 15 ++++++++-------
 drivers/net/ethernet/mellanox/mlx4/fw.c         |  9 +++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.h         |  1 +
 drivers/net/ethernet/mellanox/mlx4/main.c       |  2 ++
 include/linux/mlx4/device.h                     |  1 +
 5 files changed, 19 insertions(+), 9 deletions(-)

-- 
1.8.3.1
