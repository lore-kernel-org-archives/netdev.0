From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/7] igb: removed unused tx/rx total
	bytes/packets from adapter struct
Date: Thu, 12 Nov 2009 20:37:56 -0800
Message-ID: <20091113043756.1240.6977.stgit@localhost.localdomain>
References: <20091113043604.1240.80142.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:48201
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755635AbZKMEiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 23:38:09 -0500
In-Reply-To: <20091113043604.1240.80142.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes unused variables total_tx_bytes, total_tx_packets,
total_rx_bytes, and total_rx_packets from the adapter struct.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 2bb9549..63abd1c 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -249,10 +249,6 @@ struct igb_adapter {
 	u16 link_speed;
 	u16 link_duplex;
 
-	unsigned int total_tx_bytes;
-	unsigned int total_tx_packets;
-	unsigned int total_rx_bytes;
-	unsigned int total_rx_packets;
 	/* Interrupt Throttle Rate */
 	u32 rx_itr_setting;
 	u32 tx_itr_setting;

