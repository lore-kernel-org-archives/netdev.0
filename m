From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 0/2] amd-xgbe: AMD XGBE driver updates 2016-11-14
Date: Mon, 14 Nov 2016 16:38:56 -0600
Message-ID: <20161114223856.25437.13649.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <christophe.jaillet@wanadoo.fr>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0086.outbound.protection.outlook.com ([104.47.41.86]:24720
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752842AbcKNWjG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 17:39:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resending with net-next in the subject)

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
