From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/3] Mellanox Ethernet driver updates 2013-04-11
Date: Thu, 11 Apr 2013 14:56:39 +0300
Message-ID: <1365681402-19445-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:38063 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754657Ab3DKL4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 07:56:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains updates to mlx4 driver.
First two patches enable SRIOV guests running old mlx4 drivers with B0 steering
only to run over hypervisor with new drivers that is using device managed flow
steering (DMFS).
Third patch is a fix to set corret MTU in SRIOV.

Thanks,
Amir


Eugenia Emantayev (1):
  net/mlx4_en: set correct MTU in SRIOV

Hadar Hen Zion (2):
  net/mlx4_core: Add helper function to translate B0 steering rules to
    DMFS
  net/mlx4_core: Translate guest B0 steering rules to DMFS

 drivers/net/ethernet/mellanox/mlx4/mcg.c           |   51 +++++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    4 +
 drivers/net/ethernet/mellanox/mlx4/port.c          |    4 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   85 +++++++++++++++-----
 4 files changed, 99 insertions(+), 45 deletions(-)

-- 
1.7.8.2
