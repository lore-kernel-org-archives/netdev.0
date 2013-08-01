From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH ethtool]: Add strings to display Supported Ports for Backplane Ethernet
Date: Thu, 1 Aug 2013 17:39:06 +0530
Message-ID: <ac83fc1a-a967-4035-bfed-a8deff029ace@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Somnath Kotur <somnath.kotur@emulex.com>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:30350 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab3HAMKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 08:10:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 3544f0e..b24b572 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -485,6 +485,9 @@ static void dump_supported(struct ethtool_cmd *ep)
 		fprintf(stdout, "MII ");
 	if (mask & SUPPORTED_FIBRE)
 		fprintf(stdout, "FIBRE ");
+	if ((mask & SUPPORTED_10000baseKR_Full) ||
+	    (mask & SUPPORTED_10000baseKX4_Full))
+		fprintf(stdout, "BACKPLANE ");
 	fprintf(stdout, "]\n");
 
 	dump_link_caps("Supported", "Supports", mask, 0);
-- 
1.7.1
