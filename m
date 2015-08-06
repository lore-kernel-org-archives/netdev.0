From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/7] mlxsw: Couple of fixes/adjustments
Date: Thu,  6 Aug 2015 16:41:51 +0200
Message-ID: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37009 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbHFOmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 10:42:03 -0400
Received: by wibhh20 with SMTP id hh20so27387625wib.0
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 07:42:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (5):
  mlxsw: Call free_netdev when removing port
  mlxsw: Make system port to local port mapping explicit
  mlxsw: Simplify mlxsw_sx_port_xmit function
  mlxsw: Use correct skb length when dumping payload
  mlxsw: Fix use-after-free bug in mlxsw_sx_port_xmit

Jiri Pirko (2):
  mlxsw: Make pci module dependent on HAS_DMA and HAS_IOMEM
  mlxsw: Strip FCS from incoming packets

 drivers/net/ethernet/mellanox/mlxsw/Kconfig    |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 12 +++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  5 +++
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 26 ++++++++---
 drivers/net/ethernet/mellanox/mlxsw/pci.h      |  6 +++
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 60 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 48 ++++++++++++++-------
 7 files changed, 135 insertions(+), 24 deletions(-)

-- 
1.9.3
