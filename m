From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 08/23] e1000: add multicast stats counters
Date: Tue, 19 Sep 2006 10:28:50 -0700
Message-ID: <20060919172850.4605.81213.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:17421 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030342AbWISRTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:55 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index a954746..0d329d6 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -60,6 +60,10 @@ static const struct e1000_stats e1000_gs
 	{ "tx_packets", E1000_STAT(net_stats.tx_packets) },
 	{ "rx_bytes", E1000_STAT(net_stats.rx_bytes) },
 	{ "tx_bytes", E1000_STAT(net_stats.tx_bytes) },
+	{ "rx_broadcast", E1000_STAT(stats.bprc) },
+	{ "tx_broadcast", E1000_STAT(stats.bptc) },
+	{ "rx_multicast", E1000_STAT(stats.mprc) },
+	{ "tx_multicast", E1000_STAT(stats.mptc) },
 	{ "rx_errors", E1000_STAT(net_stats.rx_errors) },
 	{ "tx_errors", E1000_STAT(net_stats.tx_errors) },
 	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },



---
Auke Kok <auke-jan.h.kok@intel.com>
