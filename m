From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 0/2] amd-xgbe: AMD XGBE driver updates 2014-11-06
Date: Thu, 6 Nov 2014 17:02:07 -0600
Message-ID: <20141106230207.21973.67338.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0113.outbound.protection.outlook.com ([157.56.111.113]:34080
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751232AbaKFXCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 18:02:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches fixes a couple of bugs that slipped
through my last series.

- Free channel structure after freeing the per channel interrupts
- If an skb error allocation occurs during receive processing check
  whether more descriptors are associated with the packet or whether
  to start on a new packet

This patch series is based on net-next.

---

Tom Lendacky (2):
      amd-xgbe: Free channel/ring structures later
      amd-xgbe: Check for complete packet on skb allocation error


 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

-- 
Tom Lendacky
