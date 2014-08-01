From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 0/2] amd-xgbe: AMD XGBE driver update 2014-08-01
Date: Fri, 1 Aug 2014 11:56:23 -0500
Message-ID: <20140801165623.20602.457.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0240.outbound.protection.outlook.com ([207.46.163.240]:45169
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751204AbaHAQ4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 12:56:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes minor fixes/updates to the
driver.

- Remove some uses of spinlock around ethtool/phylib areas
- Update Rx/Tx ready check logic

This patch series is based on net-next.

---

Tom Lendacky (2):
      amd-xgbe: Remove unnecessary spinlocks
      amd-xgbe-phy: Allow more time for Rx/Tx to become ready


 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   20 +++++---------------
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |    5 -----
 drivers/net/phy/amd-xgbe-phy.c               |    6 +++---
 3 files changed, 8 insertions(+), 23 deletions(-)

-- 
Tom Lendacky
