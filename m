From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool 3/3] ethtool.8.in: Add man page for rx_copybreak
Date: Sat, 13 Sep 2014 15:26:47 +0530
Message-ID: <1410602207-9084-4-git-send-email-_govind@gmx.com>
References: <1410602207-9084-1-git-send-email-_govind@gmx.com>
Cc: netdev@vger.kernel.org, ssujith@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:50943 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbaIMJ5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2014 05:57:49 -0400
In-Reply-To: <1410602207-9084-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 ethtool.8.in | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index bb394cc..e3d1f13 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -176,6 +176,13 @@ ethtool \- query or control network driver and hardware settings
 .BN rx\-jumbo
 .BN tx
 .HP
+.B ethtool \-b|\-\-show\-rx_copybreak
+.I devname
+.HP
+.B ethtool \-B|\-\-set\-rx_copybreak
+.I devname
+.RI [ N ]
+.HP
 .B ethtool \-i|\-\-driver
 .I devname
 .HP
@@ -398,6 +405,17 @@ Changes the number of ring entries for the Rx Jumbo ring.
 .BI tx \ N
 Changes the number of ring entries for the Tx ring.
 .TP
+.B \-b|\-\-show\-rx_copybreak
+Get rx_copybreak value
+.TP
+.B \-B|\-\-set\-rx_copybreak
+Set rx_copybreak value
+.TP
+.B N
+rx_copybreak value in bytes. Any packet with length less than this value will
+be copied to newly allocated skb. DMA mapped skb is reused and put back in
+rx queue.
+.TP
 .B \-i \-\-driver
 Queries the specified network device for associated driver information.
 .TP
-- 
2.1.0
