From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v2 0/2] amd-xgbe: AMD XGBE driver fixes 2014-12-02
Date: Wed, 3 Dec 2014 08:36:31 -0600
Message-ID: <20141203143630.25084.91079.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0123.outbound.protection.outlook.com ([65.55.169.123]:3904
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752139AbaLCOgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 09:36:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes two bug fixes. Unfortunately,
the first patch will create a conflict when eventually merged into
net-next but should be very easy to resolve.

- Do not clear the interrupt bit in the xgbe_ring_data structure
- Associate a Tx SKB with the proper xgbe_ring_data structure

This patch series is based on net.

Changes from v1:
- Update the commit message associated with the first patch

---

Tom Lendacky (2):
      amd-xgbe: Do not clear interrupt indicator
      amd-xgbe: Associate Tx SKB with proper ring descriptor


 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

-- 
Tom Lendacky
