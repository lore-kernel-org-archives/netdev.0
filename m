From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH ethtool V3 2/2] ethtool.8.in: Add man page for tunable copybreak
Date: Thu, 11 Jun 2015 15:15:28 +0300
Message-ID: <1434024928-33177-3-git-send-email-hadarh@mellanox.com>
References: <1434024928-33177-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, _govind@gmx.com,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49594 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753016AbbFKMQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 08:16:14 -0400
In-Reply-To: <1434024928-33177-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 ethtool.8.in | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index ae56293..eae630e 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -176,6 +176,14 @@ ethtool \- query or control network driver and hardware settings
 .BN rx\-jumbo
 .BN tx
 .HP
+.B ethtool \-b|\-\-show\-tunable
+.I devname
+.HP
+.B ethtool \-B|\-\-set\-tunable
+.I devname
+.BN rx-copybreak
+.BN tx-copybreak
+.HP
 .B ethtool \-i|\-\-driver
 .I devname
 .HP
@@ -399,6 +407,18 @@ Changes the number of ring entries for the Rx Jumbo ring.
 .BI tx \ N
 Changes the number of ring entries for the Tx ring.
 .TP
+.B \-b|\-\-show\-tunable
+Get device tunable values
+.TP
+.B \-B|\-\-set\-tunable
+Set device tunable values
+.TP
+.BI rx-copybreak \ N
+Change rx_copybreak
+.TP
+.BI tx-copybreak \ N
+Change tx_copybreak
+.TP
 .B \-i \-\-driver
 Queries the specified network device for associated driver information.
 .TP
-- 
1.8.3.1
