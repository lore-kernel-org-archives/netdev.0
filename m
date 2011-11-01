From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 07/21] Fix format of help text for -f option
Date: Tue, 1 Nov 2011 23:15:22 +0000
Message-ID: <1320189323.2758.37.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37962 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086Ab1KAXP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:15:26 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index f772f61..aab1e41 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -229,9 +229,9 @@ static struct option {
 		"options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
 		"tcp6|udp6|ah6|esp6|sctp6 ]\n" },
-    { "-f", "--flash", MODE_FLASHDEV, "FILENAME " "Flash firmware image "
+    { "-f", "--flash", MODE_FLASHDEV, "Flash firmware image "
     		"from the specified file to a region on the device",
-		"               [ REGION-NUMBER-TO-FLASH ]\n" },
+		"               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
     { "-N", "--config-nfc", MODE_SNFC, "Configure Rx network flow "
 		"classification options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
