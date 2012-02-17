From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 4/4] ethtool.8: Improve description of RX NFC options
Date: Fri, 17 Feb 2012 20:55:32 +0000
Message-ID: <1329512132.2822.8.camel@bwh-desktop>
References: <1329512042.2822.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15513 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754469Ab2BQUzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 15:55:35 -0500
In-Reply-To: <1329512042.2822.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

State explicitly that arguments beginning with 'flow-type' will
insert or update a rule.

Refer consistently to 'flow type' rather than 'network traffic type'.

Refer to 'options and rules', covering both flow hashing and
steering/filtering.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 4c46096..3567352 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -590,10 +590,10 @@ The precise meanings of these type flags differ between drivers.
 .RE
 .TP
 .B \-n \-u \-\-show\-nfc \-\-show\-ntuple
-Retrieves the receive network flow classification configurations.
+Retrieves receive network flow classification options or rules.
 .TP
 .BR rx\-flow\-hash \ \*(FL
-Retrieves the hash options for the specified network traffic type.
+Retrieves the hash options for the specified flow type.
 .TS
 nokeep;
 lB	l.
@@ -615,10 +615,10 @@ Retrieves the RX classification rule with the given ID.
 .RE
 .TP
 .B \-N \-U \-\-config\-nfc \-\-config\-ntuple
-Configures the receive network flow classification.
+Configures receive network flow classification options or rules.
 .TP
 .BR rx\-flow\-hash \ \*(FL \: \*(HO
-Configures the hash options for the specified network traffic type.
+Configures the hash options for the specified flow type.
 .TS
 nokeep;
 lB	l.
@@ -636,6 +636,7 @@ T}
 .TE
 .TP
 .B flow\-type \*(NC
+Inserts or updates a classification rule for the specified flow type.
 .TS
 nokeep;
 lB	l.
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
