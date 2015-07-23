From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH v1 0/6] net: netcp: Bug fixes of CPSW statistics collection
Date: Thu, 23 Jul 2015 15:57:18 -0400
Message-ID: <1437681444-23109-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set contains bug fixes and enhencements of hw ethernet
statistics processing on TI's Keystone2 CPSW ethernet switches.

v1: Removes unused defines in PATCH 3/6 based on reviewer's comment

WingMan Kwok (6):
  net: netcp: Fixes the use of spin_lock_bh in timer function
  net: netcp: Fixes hw statistics module base setting error
  net: netcp: Fixes error in oversized memory allocation for statistics
    storage
  net: netcp: Consolidates statistics collection code
  net: netcp: Fixes to CPSW statistics collection
  net: netcp: Adds missing statistics for K2L and K2E

 drivers/net/ethernet/ti/netcp_ethss.c |  403 ++++++++++++++++++++++++++-------
 1 file changed, 324 insertions(+), 79 deletions(-)

-- 
1.7.9.5
