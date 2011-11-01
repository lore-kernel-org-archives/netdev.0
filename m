From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 06/21] ethtool.8: Allow line-break in description
 of parameters after -N
Date: Tue, 1 Nov 2011 23:15:14 +0000
Message-ID: <1320189314.2758.36.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37949 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab1KAXPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:15:19 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These lines are currently unbreakable and result in ugly wrapping
in an 80-column window.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 65392d6..3304fe5 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -256,7 +256,7 @@ ethtool \- query or control network driver and hardware settings
 .HP
 .B ethtool \-N
 .I devname
-.RB [ rx\-flow\-hash \ \*(FL \  \*(HO]
+.RB [ rx\-flow\-hash \ \*(FL \: \*(HO]
 .HP
 .B ethtool \-w|\-\-get\-dump
 .I devname
@@ -605,7 +605,7 @@ sctp6	SCTP over IPv6
 .B \-N \-\-config\-nfc
 Configures the receive network flow classification.
 .TP
-.BR rx\-flow\-hash \ \*(FL \ \*(HO
+.BR rx\-flow\-hash \ \*(FL \: \*(HO
 Configures the hash options for the specified network traffic type.
 .TS
 nokeep;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
