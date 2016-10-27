From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] mlxsw: small driver update
Date: Thu, 27 Oct 2016 15:12:56 +0200
Message-ID: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33357 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965706AbcJ0OYB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:24:01 -0400
Received: by mail-wm0-f48.google.com with SMTP id 79so5405719wmy.0
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 07:24:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

For details, see individual patches.

Ido Schimmel (1):
  mlxsw: spectrum: Remove extra whitespace

Jiri Pirko (4):
  mlxsw: pci: Rename header with HW definitions
  mlxsw: Move PCI id table definitions into driver modules
  mlxsw: spectrum: Set physical device for port netdevice
  mlxsw: switchx2: Set physical device for port netdevice

 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/core.c         |  14 --
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   8 -
 drivers/net/ethernet/mellanox/mlxsw/pci.c          |  56 ++---
 drivers/net/ethernet/mellanox/mlxsw/pci.h          | 206 ++----------------
 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h       | 229 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  26 ++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |  35 +++-
 9 files changed, 323 insertions(+), 257 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h

-- 
2.5.5
