From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/4] Move '--flash' down the list of options
Date: Fri, 17 Feb 2012 20:54:44 +0000
Message-ID: <1329512084.2822.5.camel@bwh-desktop>
References: <1329512042.2822.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15456 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752642Ab2BQUyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 15:54:46 -0500
In-Reply-To: <1329512042.2822.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't make sense to to list it between the two RX NFC options in
the online help.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index d0cc7d4..1f496dd 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3206,9 +3206,6 @@ static const struct option {
 	  "Show Rx network flow classification options",
 	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
 	  "tcp6|udp6|ah6|esp6|sctp6 ]\n" },
-	{ "-f|--flash", 1, do_flash,
-	  "Flash firmware image from the specified file to a region on the device",
-	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
 	{ "-N|--config-nfc", 1, do_srxclass,
 	  "Configure Rx network flow classification options",
 	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
@@ -3218,6 +3215,9 @@ static const struct option {
 	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
 	  "Set Rx flow hash indirection",
 	  "		equal N | weight W0 W1 ...\n" },
+	{ "-f|--flash", 1, do_flash,
+	  "Flash firmware image from the specified file to a region on the device",
+	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
 	{ "-U|--config-ntuple", 1, do_srxclsrule,
 	  "Configure Rx ntuple filters and actions",
 	  "		[ delete %d ] |\n"
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
