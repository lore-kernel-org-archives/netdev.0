From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] net/mlx4: fixes for ndo VF control calls
Date: Wed,  8 May 2013 15:30:26 +0300
Message-ID: <1368016228-19783-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:51966 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754323Ab3EHMaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 08:30:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These are two fixes to the mlx4 implementation of ndo_set_vf calls
we added in the 3.10 merge window.

Or.

Or Gerlitz (1):
  net/mlx4_core: Add missing report on VST and spoof-checking dev caps

Rony Efraim (1):
  net/mlx4: Strengthen VLAN tags/priorities enforcement in VST mode

 drivers/net/ethernet/mellanox/mlx4/en_resources.c  |    2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    4 ++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   29 +++++++++++--------
 include/linux/mlx4/qp.h                            |   29 ++++++++++++++++++-
 4 files changed, 48 insertions(+), 16 deletions(-)
