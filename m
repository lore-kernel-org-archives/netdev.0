From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool 1/2] Remove short option -I for PHY statistics
Date: Sun, 13 Mar 2016 16:01:20 +0000
Message-ID: <20160313160120.GB21187@decadent.org.uk>
References: <1450871911-19509-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40721 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753553AbcCMQBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 12:01:23 -0400
Content-Disposition: inline
In-Reply-To: <1450871911-19509-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not mnemonic and there's no requirement to have short options
for every command.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 ethtool.8.in | 4 ++--
 ethtool.c    | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 2316556d65de..e44db99dc5d6 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -220,7 +220,7 @@ ethtool \- query or control network driver and hardware settings
 .B ethtool \-S|\-\-statistics
 .I devname
 .HP
-.B ethtool \-I|\-\-phy-statistics
+.B \-\-phy\-statistics
 .I devname
 .HP
 .B ethtool \-t|\-\-test
@@ -495,7 +495,7 @@ auto-negotiation is enabled.
 Queries the specified network device for NIC- and driver-specific
 statistics.
 .TP
-.B \-I \-\-phy\-statistics
+.B \-\-phy\-statistics
 Queries the specified network device for PHY specific statistics.
 .TP
 .B \-t \-\-test
diff --git a/ethtool.c b/ethtool.c
index 480c14c8d30c..1c988f7d8a9d 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4136,7 +4136,7 @@ static const struct option {
 	{ "-t|--test", 1, do_test, "Execute adapter self test",
 	  "               [ online | offline | external_lb ]\n" },
 	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
-	{ "-I|--phy-statistics", 1, do_gphystats,
+	{ "--phy-statistics", 1, do_gphystats,
 	  "Show phy statistics" },
 	{ "-n|-u|--show-nfc|--show-ntuple", 1, do_grxclass,
 	  "Show Rx network flow classification options or rules",
