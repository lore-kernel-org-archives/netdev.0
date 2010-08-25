From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 2/2] be2net: stats for packets received due to
 internal switching in ASIC.
Date: Wed, 25 Aug 2010 16:02:56 +0530
Message-ID: <20100825103246.GA15665@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:39870 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753110Ab0HYKcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 06:32:52 -0400
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
index cd16243..9bedb9f 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -90,6 +90,9 @@ static const struct be_ethtool_stat et_stats[] = {
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

