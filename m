From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 0/2] amd-xgbe: AMD XGBE driver fixes 2014-09-05
Date: Fri, 5 Sep 2014 18:02:24 -0500
Message-ID: <20140905230224.27896.64932.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0112.outbound.protection.outlook.com ([65.55.169.112]:37984
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752428AbaIEXCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 19:02:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes fixes to the driver.

- Proper access to 64 bit management counter registers
- Enable all management counter registers to generate an interrupt when
  the counter threshold is reached

This patch series is based on net.

---

Tom Lendacky (2):
      amd-xgbe: Treat certain counter registers as 64 bit
      amd-xgbe: Enable interrupts for all management counters


 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |  194 +++++++++++++++++-------------
 1 file changed, 110 insertions(+), 84 deletions(-)

-- 
Tom Lendacky
