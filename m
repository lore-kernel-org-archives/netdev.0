From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] ethtool: remove mask for Auto in advertise section
Date: Fri,  4 Mar 2011 23:27:01 -0800
Message-ID: <1299310021-29027-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49165 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720Ab1CEH1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 02:27:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The mask for Auto in the advertise section is incorrect for any interface
that supports speeds > 1000Mbps. Since the description already states that
the mask can be a combination of the supported values it's probably better
to just remove it. 'Auto' was misleading anyway.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ethtool.8.in |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 0ee91a0..d7bcc51 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -516,8 +516,6 @@ a hexadecimal value using one or a combination of the following values:
 .BR "0x8000" "   2500 Full" "(not supported by IEEE standards)"
 .TP 3
 .BR "0x1000" "   10000 Full"
-.TP 3
-.BR "0x03F" "    Auto"
 .PD
 .RE
 .TP
-- 
1.7.4

