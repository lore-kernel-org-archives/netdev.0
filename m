From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH v0 0/6] net: netcp: Bug fixes of CPSW statistics collection
Date: Thu, 23 Jul 2015 09:32:42 -0400
Message-ID: <1437658368-1679-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:38150 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752599AbbGWNdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:33:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains bug fixes and enhencements of hw ethernet
statistics processing on TI's Keystone2 CPSW ethernet switches.

WingMan Kwok (6):
  net: netcp: Fixes the use of spin_lock_bh in timer function
  net: netcp: Fixes hw statistics module base setting error
  net: netcp: Fixes error in oversized memory allocation for statistics
    storage
  net: netcp: Consolidates statistics collection code
  net: netcp: Fixes to CPSW statistics collection
  net: netcp: Adds missing statistics for K2L and K2E

 drivers/net/ethernet/ti/netcp_ethss.c |  399 ++++++++++++++++++++++++++-------
 1 file changed, 324 insertions(+), 75 deletions(-)

-- 
1.7.9.5
