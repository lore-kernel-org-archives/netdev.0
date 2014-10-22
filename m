From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 0/2] amd-xgbe: AMD XGBE driver fixes 2014-10-22
Date: Wed, 22 Oct 2014 11:26:05 -0500
Message-ID: <20141022162605.31495.98889.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0143.outbound.protection.outlook.com ([157.56.111.143]:15003
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753162AbaJVQmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 12:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes fixes to the driver.

- Properly handle feature changes via ethtool by using correctly sized
  variables
- Perform proper napi packet counting and budget checking

This patch series is based on net.

---

Tom Lendacky (2):
      amd-xgbe: Properly handle feature changes via ethtool
      amd-xgbe: Fix napi Rx budget accounting


 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

-- 
Tom Lendacky
