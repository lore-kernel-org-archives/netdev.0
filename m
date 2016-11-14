From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH 0/2] amd-xgbe: AMD XGBE driver updates 2016-11-14
Date: Mon, 14 Nov 2016 16:28:27 -0600
Message-ID: <20161114222827.25160.24791.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <christophe.jaillet@wanadoo.fr>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0086.outbound.protection.outlook.com ([104.47.38.86]:58432
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965140AbcKNW2r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 17:28:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series addresses some minor issues found in the recently
accepted patch series for the AMD XGBE driver.

The following fixes are included in this driver update series:

- Fix how a mask is applied to a Clause 37 register value
- Fix some coccinelle identified warnings

This patch series is based on net-next.

---

Tom Lendacky (2):
      amd-xgbe: Fix mask appliciation for Clause 37 register
      amd-xgbe: Fix up some coccinelle identified warnings


 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c   |    4 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |    5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

-- 
Tom Lendacky
