From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 00/10] mlx4 misc fixes for 4.9
Date: Thu, 27 Oct 2016 16:27:12 +0300
Message-ID: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57522 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941405AbcJ0NyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains several bug fixes from the team to the
mlx4 Eth and Core drivers.

Series generated against net commit:
ecc515d7238f 'sctp: fix the panic caused by route update'

Thanks,
Tariq.

Erez Shitrit (1):
  net/mlx4_en: Process all completions in RX rings after port goes up

Eugenia Emantayev (3):
  net/mlx4_en: Resolve dividing by zero in 32-bit system
  net/mlx4_en: Fix panic during reboot
  net/mlx4: Fix firmware command timeout during interrupt test

Jack Morgenstein (3):
  net/mlx4_core: Fix the resource-type enum in res tracker to conform to
    FW spec
  net/mlx4_core: Do not access comm channel if it has not yet been
    initialized
  net/mlx4_en: Fix potential deadlock in port statistics flow

Maor Gottlieb (1):
  net/mlx4_core: Avoid setting ports to auto when only one port type is
    supported

Moshe Lazer (1):
  net/mlx4_core: Change the default value of enable_qos

Tariq Toukan (1):
  net/mlx4_en: Save slave ethtool stats command

 drivers/net/ethernet/mellanox/mlx4/cmd.c         |  9 ++++
 drivers/net/ethernet/mellanox/mlx4/en_clock.c    |  5 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   | 13 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c     |  4 +-
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c | 26 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c          | 62 +++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/fw.c          |  4 +-
 drivers/net/ethernet/mellanox/mlx4/main.c        | 10 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h        |  5 +-
 drivers/net/ethernet/mellanox/mlx4/port.c        | 13 +----
 include/linux/mlx4/device.h                      |  3 +-
 11 files changed, 95 insertions(+), 59 deletions(-)

-- 
1.8.3.1
