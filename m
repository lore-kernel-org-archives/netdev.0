From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 0/4] Mellanox driver updates 2013-08-19
Date: Tue, 20 Aug 2013 18:42:45 +0300
Message-ID: <1377013369-14711-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39436 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751626Ab3HTPnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 11:43:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This small patchset contains 2 fixes to bad handling of error flows in TX
datapath, and a fix to a bug in mlx4_en_dcbnl_ieee_setpfc() where global pause
frames were enabled whenever PFC was configured.
Also added a patch to reduce the scope of some local variables in the moved
block of code and it's surrounding.

Thanks,
Amir

---
Changes from V0:
- Missing new lines + typo's
- Fixed frags dma leak
- Use local for ddev
- New patch (4/4), to reduce scope of some locals

Amir Vadai (3):
  net/mlx4_en: Notify user when TX ring in error state
  net/mlx4_en: Fix handling of dma_map failure
  net/mlx4_en: Reduce scope of local variables in mlx4_en_xmit

Eugenia Emantayev (1):
  net/mlx4_en: Disable global flow control when PFC enabled

 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   3 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 116 +++++++++++++++++--------
 2 files changed, 80 insertions(+), 39 deletions(-)

-- 
1.8.3.4
