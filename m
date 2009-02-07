From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 10/26] igb: remove unused rx_hdr_split statistic
Date: Sat, 07 Feb 2009 01:18:06 -0800
Message-ID: <20090207091806.15697.51699.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:50304
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752644AbZBGJS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:18:27 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This statistic is not used and so it is safe to remove

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    1 -
 drivers/net/igb/igb_ethtool.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index a2a812d..88fdfe4 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -238,7 +238,6 @@ struct igb_adapter {
 
 	u64 hw_csum_err;
 	u64 hw_csum_good;
-	u64 rx_hdr_split;
 	u32 alloc_rx_buff_failed;
 	bool rx_csum;
 	u32 gorc;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index a5bf8ef..84be46c 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -88,7 +88,6 @@ static const struct igb_stats igb_gstrings_stats[] = {
 	{ "rx_long_byte_count", IGB_STAT(stats.gorc) },
 	{ "rx_csum_offload_good", IGB_STAT(hw_csum_good) },
 	{ "rx_csum_offload_errors", IGB_STAT(hw_csum_err) },
-	{ "rx_header_split", IGB_STAT(rx_hdr_split) },
 	{ "alloc_rx_buff_failed", IGB_STAT(alloc_rx_buff_failed) },
 	{ "tx_smbus", IGB_STAT(stats.mgptc) },
 	{ "rx_smbus", IGB_STAT(stats.mgprc) },

