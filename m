From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6 5/6] be2net: stats for packets received due to
 internal switching in ASIC.
Date: Sun, 22 Aug 2010 14:57:18 +0530
Message-ID: <20100822092708.GA22308@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:2455 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752060Ab0HVJ1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 05:27:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Counters for packets received due to internal switching are already available.
This change will start displaying them in ethtool -S

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 13f0abb..d920634 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -91,6 +91,9 @@ static const struct be_ethtool_stat et_stats[] = {
 	{PORTSTAT_INFO(rx_non_rss_packets)},
 	{PORTSTAT_INFO(rx_ipv4_packets)},
 	{PORTSTAT_INFO(rx_ipv6_packets)},
+	{PORTSTAT_INFO(rx_switched_unicast_packets)},
+	{PORTSTAT_INFO(rx_switched_multicast_packets)},
+	{PORTSTAT_INFO(rx_switched_broadcast_packets)},
 	{PORTSTAT_INFO(tx_unicastframes)},
 	{PORTSTAT_INFO(tx_multicastframes)},
 	{PORTSTAT_INFO(tx_broadcastframes)},
-- 
1.7.0.4

