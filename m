From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 1/2] Add macro for displaying [value N] formatting to
	manpage
Date: Thu, 10 Feb 2011 17:18:33 -0800
Message-ID: <20110211011833.23554.32698.stgit@gitlad.jf.intel.com>
References: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21645 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757378Ab1BKBSe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 20:18:34 -0500
In-Reply-To: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds a macro for displaying optional values that take a numeric
value to the manpage.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool.8.in |  102 ++++++++++++++++++++++------------------------------------
 1 files changed, 38 insertions(+), 64 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 0ee91a0..133825b 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -34,6 +34,12 @@
 [\\fB\\$1\\fP\ \\fB\\$2\\fP|\\fB\\$3\\fP|\\fB\\$4\\fP|\\fB\\$5\\fP]
 ..
 .\"
+.\"	.BN - value with a numeric input as in "[value N]"
+.\"
+.de BN
+[\\fB\\$1\\fP\ \\fIN\\fP]
+..
+.\"
 .\"	\(*MA - mac address
 .\"
 .ds MA \fIxx\fP\fB:\fP\fIyy\fP\fB:\fP\fIzz\fP\fB:\fP\fIaa\fP\fB:\fP\fIbb\fP\fB:\fP\fIcc\fP
@@ -110,60 +116,36 @@ ethtool \- query or control network driver and hardware settings
 .I ethX
 .B2 adaptive-rx on off
 .B2 adaptive-tx on off
-.RB [ rx-usecs
-.IR N ]
-.RB [ rx-frames
-.IR N ]
-.RB [ rx-usecs-irq
-.IR N ]
-.RB [ rx-frames-irq
-.IR N ]
-.RB [ tx-usecs
-.IR N ]
-.RB [ tx-frames
-.IR N ]
-.RB [ tx-usecs-irq
-.IR N ]
-.RB [ tx-frames-irq
-.IR N ]
-.RB [ stats-block-usecs
-.IR N ]
-.RB [ pkt-rate-low
-.IR N ]
-.RB [ rx-usecs-low
-.IR N ]
-.RB [ rx-frames-low
-.IR N ]
-.RB [ tx-usecs-low
-.IR N ]
-.RB [ tx-frames-low
-.IR N ]
-.RB [ pkt-rate-high
-.IR N ]
-.RB [ rx-usecs-high
-.IR N ]
-.RB [ rx-frames-high
-.IR N ]
-.RB [ tx-usecs-high
-.IR N ]
-.RB [ tx-frames-high
-.IR N ]
-.RB [ sample-interval
-.IR N ]
+.BN rx-usecs
+.BN rx-frames
+.BN rx-usecs-irq
+.BN rx-frames-irq
+.BN tx-usecs
+.BN tx-frames
+.BN tx-usecs-irq
+.BN tx-frames-irq
+.BN stats-block-usecs
+.BN pkt-rate-low
+.BN rx-usecs-low
+.BN rx-frames-low
+.BN tx-usecs-low
+.BN tx-frames-low
+.BN pkt-rate-high
+.BN rx-usecs-high
+.BN rx-frames-high
+.BN tx-usecs-high
+.BN tx-frames-high
+.BN sample-interval
 
 .B ethtool \-g|\-\-show\-ring
 .I ethX
 
 .B ethtool \-G|\-\-set\-ring
 .I ethX
-.RB [ rx
-.IR N ]
-.RB [ rx-mini
-.IR N ]
-.RB [ rx-jumbo
-.IR N ]
-.RB [ tx
-.IR N ]
+.BN rx
+.BN rx-mini
+.BN rx-jumbo
+.BN tx
 
 .B ethtool \-i|\-\-driver
 .I ethX
@@ -178,21 +160,15 @@ ethtool \- query or control network driver and hardware settings
 .B ethtool \-e|\-\-eeprom\-dump
 .I ethX
 .B2 raw on off
-.RB [ offset
-.IR N ]
-.RB [ length
-.IR N ]
+.BN offset
+.BN length
 
 .B ethtool \-E|\-\-change\-eeprom
 .I ethX
-.RB [ magic
-.IR N ]
-.RB [ offset
-.IR N ]
-.RB [ length
-.IR N ]
-.RB [ value
-.IR N ]
+.BN magic
+.BN offset
+.BN length
+.BN value
 
 .B ethtool \-k|\-\-show\-offload
 .I ethX
@@ -234,10 +210,8 @@ ethtool \- query or control network driver and hardware settings
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
 .B2 autoneg on off
-.RB [ advertise
-.IR N ]
-.RB [ phyad
-.IR N ]
+.BN advertise
+.BN phyad
 .B2 xcvr internal external
 .RB [ wol \ \*(WO]
 .RB [ sopass \ \*(MA]

