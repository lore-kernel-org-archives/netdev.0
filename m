From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool v2 3/3] ethtool.8.in: Add man page for copybreak
Date: Tue,  7 Oct 2014 04:42:21 +0530
Message-ID: <1412637141-3205-4-git-send-email-_govind@gmx.com>
References: <1412637141-3205-1-git-send-email-_govind@gmx.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:64465 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbaJFXNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 19:13:17 -0400
In-Reply-To: <1412637141-3205-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 ethtool.8.in | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index ae56293..9f0955f 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -176,6 +176,14 @@ ethtool \- query or control network driver and hardware settings
 .BN rx\-jumbo
 .BN tx
 .HP
+.B ethtool \-b|\-\-show\-copybreak
+.I devname
+.HP
+.B ethtool \-B|\-\-set\-copybreak
+.I devname
+.BN rx
+.BN tx
+.HP
 .B ethtool \-i|\-\-driver
 .I devname
 .HP
@@ -399,6 +407,18 @@ Changes the number of ring entries for the Rx Jumbo ring.
 .BI tx \ N
 Changes the number of ring entries for the Tx ring.
 .TP
+.B \-b|\-\-show\-copybreak
+Get device copybreak values
+.TP
+.B \-B|\-\-set\-copybreak
+Set device copybreak values
+.TP
+.BI rx \ N
+Change rx_copybreak
+.TP
+.BI tx \ N
+Change tx_copybreak
+.TP
 .B \-i \-\-driver
 Queries the specified network device for associated driver information.
 .TP
-- 
2.1.0
