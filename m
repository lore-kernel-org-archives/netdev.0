From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/3] Mellanox driver updates 2013-08-19
Date: Mon, 19 Aug 2013 09:42:19 +0300
Message-ID: <1376894542-27854-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42155 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750838Ab3HSGmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:42:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This small patchset contains 2 fixes to bad handling of error flows in TX
datapath, and a fix to a bug in mlx4_en_dcbnl_ieee_setpfc() where global pause
frames were enabled whenever PFC was configured.

Thanks,
Amir

Amir Vadai (2):
  net/mlx4_en: Notify user when TX ring in error state
  net/mlx4_en: Fix handling of dma_map failure

Eugenia Emantayev (1):
  net/mlx4_en: Disable global flow control when PFC enabled

 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   3 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 102 ++++++++++++++++---------
 2 files changed, 69 insertions(+), 36 deletions(-)

-- 
1.8.3.4
