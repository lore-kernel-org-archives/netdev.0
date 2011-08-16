From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/5] ethtool: Specify what kind of coalescing
 struct ethtool_coalesce covers
Date: Tue, 16 Aug 2011 01:07:15 +0100
Message-ID: <1313453235.2731.58.camel@bwh-desktop>
References: <1313453180.2731.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eli Cohen <eli@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:41089 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab1HPAHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 20:07:18 -0400
In-Reply-To: <1313453180.2731.57.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index be32dd0..71d45a1 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -118,7 +118,7 @@ struct ethtool_eeprom {
 };
 
 /**
- * struct ethtool_coalesce - coalescing parameters of chip
+ * struct ethtool_coalesce - coalescing parameters for IRQs and stats updates
  * @cmd: ETHTOOL_{G,S}COALESCE
  * @rx_coalesce_usecs: How many usecs to delay an RX interrupt after
  *	a packet arrives.  If 0, only @rx_max_coalesced_frames is used.
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

