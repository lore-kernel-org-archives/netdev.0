From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 05/21] ethtool.8: Change device name metavariable
 from 'ethX' to 'devname'
Date: Tue, 1 Nov 2011 23:15:02 +0000
Message-ID: <1320189302.2758.35.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37920 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755096Ab1KAXPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:15:05 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name 'ethX' is a poor choice because:
- Many ethtool options are applicable to non-Ethernet devices
- Ethernet device names don't have to begin with 'eth', and the
  new convention is to use the prefix 'lan' for LAN-on-motherboard
  or 'pci' for PCI plug-in cards

The online help text already uses 'DEVNAME' instead, so change the
manual page to be consistent.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in |   62 +++++++++++++++++++++++++++++-----------------------------
 1 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 286d089..65392d6 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -123,26 +123,26 @@ ethtool \- query or control network driver and hardware settings
 .nh
 .HP
 .B ethtool
-.I ethX
+.I devname
 .HP
 .B ethtool \-h|\-\-help
 .HP
 .B ethtool \-\-version
 .HP
 .B ethtool \-a|\-\-show\-pause
-.I ethX
+.I devname
 .HP
 .B ethtool \-A|\-\-pause
-.I ethX
+.I devname
 .B2 autoneg on off
 .B2 rx on off
 .B2 tx on off
 .HP
 .B ethtool \-c|\-\-show\-coalesce
-.I ethX
+.I devname
 .HP
 .B ethtool \-C|\-\-coalesce
-.I ethX
+.I devname
 .B2 adaptive\-rx on off
 .B2 adaptive\-tx on off
 .BN rx\-usecs
@@ -167,43 +167,43 @@ ethtool \- query or control network driver and hardware settings
 .BN sample\-interval
 .HP
 .B ethtool \-g|\-\-show\-ring
-.I ethX
+.I devname
 .HP
 .B ethtool \-G|\-\-set\-ring
-.I ethX
+.I devname
 .BN rx
 .BN rx\-mini
 .BN rx\-jumbo
 .BN tx
 .HP
 .B ethtool \-i|\-\-driver
-.I ethX
+.I devname
 .HP
 .B ethtool \-d|\-\-register\-dump
-.I ethX
+.I devname
 .B2 raw on off
 .B2 hex on off
 .RB [ file 
 .IR name ]
 .HP
 .B ethtool \-e|\-\-eeprom\-dump
-.I ethX
+.I devname
 .B2 raw on off
 .BN offset
 .BN length
 .HP
 .B ethtool \-E|\-\-change\-eeprom
-.I ethX
+.I devname
 .BN magic
 .BN offset
 .BN length
 .BN value
 .HP
 .B ethtool \-k|\-\-show\-offload
-.I ethX
+.I devname
 .HP
 .B ethtool \-K|\-\-offload
-.I ethX
+.I devname
 .B2 rx on off
 .B2 tx on off
 .B2 sg on off
@@ -217,24 +217,24 @@ ethtool \- query or control network driver and hardware settings
 .B2 rxhash on off
 .HP
 .B ethtool \-p|\-\-identify
-.I ethX
+.I devname
 .RI [ N ]
 .HP
 .B ethtool \-P|\-\-show\-permaddr
-.I ethX
+.I devname
 .HP
 .B ethtool \-r|\-\-negotiate
-.I ethX
+.I devname
 .HP
 .B ethtool \-S|\-\-statistics
-.I ethX
+.I devname
 .HP
 .B ethtool \-t|\-\-test
-.I ethX
+.I devname
 .RI [\*(SD]
 .HP
 .B ethtool \-s
-.I ethX
+.I devname
 .BI speed \ N
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
@@ -251,27 +251,27 @@ ethtool \- query or control network driver and hardware settings
 .RB ...]
 .HP
 .B ethtool \-n
-.I ethX
+.I devname
 .RB [ rx\-flow\-hash \ \*(FL]
 .HP
 .B ethtool \-N
-.I ethX
+.I devname
 .RB [ rx\-flow\-hash \ \*(FL \  \*(HO]
 .HP
 .B ethtool \-w|\-\-get\-dump
-.I ethX
+.I devname
 .RB [ data
 .IR filename ]
 .HP
 .B ethtool\ \-W|\-\-set\-dump
-.I ethX
+.I devname
 .BI \ N
 .HP
 .B ethtool \-x|\-\-show\-rxfh\-indir
-.I ethX
+.I devname
 .HP
 .B ethtool \-X|\-\-set\-rxfh\-indir
-.I ethX
+.I devname
 .RB [\  equal
 .IR N \ |
 .BI weight\  W0
@@ -279,15 +279,15 @@ ethtool \- query or control network driver and hardware settings
 .RB ...\ ]
 .HP
 .B ethtool \-f|\-\-flash
-.I ethX
+.I devname
 .RI FILE
 .RI [ N ]
 .HP
 .B ethtool \-u|\-\-show\-ntuple
-.I ethX
+.I devname
 .BN rule
 .HP
-.BI ethtool\ \-U|\-\-config\-ntuple \ ethX
+.BI ethtool\ \-U|\-\-config\-ntuple \ devname
 .BN delete
 .RB [\  flow\-type \ \*(NC
 .RB [ src \ \*(MA\ [ m \ \*(MA]]
@@ -309,10 +309,10 @@ ethtool \- query or control network driver and hardware settings
 .RB ]
 .HP
 .B ethtool \-l|\-\-show\-channels
-.I ethX
+.I devname
 .HP
 .B ethtool \-L|\-\-set\-channels
-.I ethX
+.I devname
 .BN rx
 .BN tx
 .BN other
@@ -327,7 +327,7 @@ ethtool \- query or control network driver and hardware settings
 is used to query and control network device driver and hardware
 settings, particularly for wired Ethernet devices.
 
-.I ethX
+.I devname
 is the name of the network device on which ethtool should operate.
 
 .SH OPTIONS
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
