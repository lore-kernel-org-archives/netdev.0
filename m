From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool v2] ethtool: Add ntuple to the -K option in the man page
Date: Tue,  7 Feb 2012 03:20:44 -0800
Message-ID: <1328613644-16668-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amir Hanania <amir.hanania@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18090 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751349Ab2BGLUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 06:20:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Hanania <amir.hanania@intel.com>

-v2: Added full description.
     Made the location of ntuple consistent with the ordering in
     'ethtool -h' output

Signed-off-by: Amir Hanania <amir.hanania@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ethtool.8.in |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index e6e46cc..98078ae 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -214,6 +214,7 @@ ethtool \- query or control network driver and hardware settings
 .B2 lro on off
 .B2 rxvlan on off
 .B2 txvlan on off
+.B2 ntuple on off
 .B2 rxhash on off
 .HP
 .B ethtool \-p|\-\-identify
@@ -454,6 +455,9 @@ Specifies whether RX VLAN acceleration should be enabled
 .A2 txvlan on off
 Specifies whether TX VLAN acceleration should be enabled
 .TP
+.A2 ntuple on off
+Specifies whether Rx ntuple filters and actions should be enabled
+.TP
 .A2 rxhash on off
 Specifies whether receive hashing offload should be enabled
 .TP
-- 
1.7.7.6
