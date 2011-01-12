From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/7] ethtool: Fix spelling and spacing in online
 help
Date: Wed, 12 Jan 2011 16:22:11 +0000
Message-ID: <1294849331.3946.1.camel@bwh-desktop>
References: <1294849266.3946.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	Kelly Anderson <kelly@silka.with-linux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54059 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab1ALQWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:22:14 -0500
In-Reply-To: <1294849266.3946.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kelly Anderson <kelly@silka.with-linux.com> pointed out that
the help for --show-nfc was missing a space between two words.

I checked the rest of the help text with aspell and found one
other error.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

diff --git a/ethtool.c b/ethtool.c
index 63e0ead..1afdfe4 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -224,13 +224,13 @@ static struct option {
 		"		[ offset N ]\n"
 		"		[ length N ]\n"
 		"		[ value N ]\n" },
-    { "-r", "--negotiate", MODE_NWAY_RST, "Restart N-WAY negotation" },
+    { "-r", "--negotiate", MODE_NWAY_RST, "Restart N-WAY negotiation" },
     { "-p", "--identify", MODE_PHYS_ID, "Show visible port identification (e.g. blinking)",
                 "               [ TIME-IN-SECONDS ]\n" },
     { "-t", "--test", MODE_TEST, "Execute adapter self test",
                 "               [ online | offline ]\n" },
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
-    { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification"
+    { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification "
 		"options",
 		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
 		"tcp6|udp6|ah6|sctp6 ]\n" },
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

