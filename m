From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/33] sfc: Abbreviate self-test names so they are not truncated
Date: Fri, 12 Dec 2008 12:52:45 +0000
Message-ID: <20081212125244.GL10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:36433 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757188AbYLLMws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:52:48 -0500
Content-Disposition: inline
In-Reply-To: <cover.1229085672.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change "channel" to "chan".

Shorten PHY loopback names.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 9c533e0..931ce14 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -27,9 +27,9 @@ const char *efx_loopback_mode_names[] = {
 	[LOOPBACK_XGXS]		= "XGXS",
 	[LOOPBACK_XAUI] 	= "XAUI",
 	[LOOPBACK_PHY]		= "PHY",
-	[LOOPBACK_PHYXS]	= "PHY(XS)",
-	[LOOPBACK_PCS]	 	= "PHY(PCS)",
-	[LOOPBACK_PMAPMD]	= "PHY(PMAPMD)",
+	[LOOPBACK_PHYXS]	= "PHYXS",
+	[LOOPBACK_PCS]	 	= "PCS",
+	[LOOPBACK_PMAPMD]	= "PMA/PMD",
 	[LOOPBACK_NETWORK]	= "NETWORK",
 };
 
@@ -242,10 +242,10 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
  * @strings:		Ethtool strings, or %NULL
  * @data:		Ethtool test results, or %NULL
  * @test:		Pointer to test result (used only if data != %NULL)
- * @unit_format:	Unit name format (e.g. "channel\%d")
- * @unit_id:		Unit id (e.g. 0 for "channel0")
+ * @unit_format:	Unit name format (e.g. "chan\%d")
+ * @unit_id:		Unit id (e.g. 0 for "chan0")
  * @test_format:	Test name format (e.g. "loopback.\%s.tx.sent")
- * @test_id:		Test id (e.g. "PHY" for "loopback.PHY.tx_sent")
+ * @test_id:		Test id (e.g. "PHYXS" for "loopback.PHYXS.tx_sent")
  *
  * Fill in an individual self-test entry.
  */
@@ -268,12 +268,12 @@ static void efx_fill_test(unsigned int test_index,
 			 test_format, test_id);
 		snprintf(strings[test_index].name,
 			 sizeof(strings[test_index].name),
-			 "%-9s%-17s", unit_str.name, test_str.name);
+			 "%-6s %-24s", unit_str.name, test_str.name);
 	}
 }
 
 #define EFX_PORT_NAME "port%d", 0
-#define EFX_CHANNEL_NAME(_channel) "channel%d", _channel->channel
+#define EFX_CHANNEL_NAME(_channel) "chan%d", _channel->channel
 #define EFX_TX_QUEUE_NAME(_tx_queue) "txq%d", _tx_queue->queue
 #define EFX_RX_QUEUE_NAME(_rx_queue) "rxq%d", _rx_queue->queue
 #define EFX_LOOPBACK_NAME(_mode, _counter)			\
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
