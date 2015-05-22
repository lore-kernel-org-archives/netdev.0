From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 0/3] amd-xgbe: AMD XGBE driver updates 2015-05-22
Date: Fri, 22 May 2015 16:32:03 -0500
Message-ID: <20150522213202.23869.67673.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0111.outbound.protection.outlook.com ([207.46.100.111]:37344
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945968AbbEVVcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 17:32:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches are included in this driver update series:

- Retrieve and set an additional hardware feature setting
- Fix the initial mode/speed determination when auto-negotiation is
  disabled
- Add additional netif_dbg support to the driver

This patch series is based on net-next.

---

Tom Lendacky (3):
      amd-xgbe: Add setting of a missing hardware feature
      amd-xgbe: Fix initial mode when auto-negotiation is disabled
      amd-xgbe: Add more netif_dbg output to the driver


 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |  113 +++++++++++++++++++++++++++--
 2 files changed, 105 insertions(+), 9 deletions(-)

-- 
Tom Lendacky
