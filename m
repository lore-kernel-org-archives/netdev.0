From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 0/2] amd-xgbe: AMD XGBE driver updates 2016-11-15
Date: Tue, 15 Nov 2016 16:10:55 -0600
Message-ID: <20161115221055.12403.90574.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <colin.king@canonical.com>, David Miller <davem@davemloft.net>,
        <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0048.outbound.protection.outlook.com ([104.47.32.48]:62543
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753578AbcKOWLC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 17:11:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series addresses some minor issues found in the recently
accepted patch series for the AMD XGBE driver.

The following fixes are included in this driver update series:

- Fix a possibly uninitialized variable in the debugfs support
- Fix the GPIO pin number constraint check

This patch series is based on net-next.

---

Tom Lendacky (2):
      amd-xgbe: Fix possible uninitialized variable
      amd-xgbe: Fix maximum GPIO value check


 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

-- 
Tom Lendacky
