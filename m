From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 10/10] wimax: a new API call was added, increment minor protocol version number
Date: Thu, 28 May 2009 18:12:14 -0700
Message-ID: <7481806dcfd07e9a636155554f6f4b4fbd976381.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:45064 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752368AbZE2ELn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 00:11:43 -0400
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243559425.git.inaky@linux.intel.com>
References: <cover.1243559425.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the 'state_get' API call was added, we need to increase the minor
protocol version number so applications that depend on the can check
it's presence.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 include/linux/wimax.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/wimax.h b/include/linux/wimax.h
index 2f7a6b7..4fdcc56 100644
--- a/include/linux/wimax.h
+++ b/include/linux/wimax.h
@@ -59,7 +59,7 @@ enum {
 	 * M - Major: change if removing or modifying an existing call.
 	 * m - minor: change when adding a new call
 	 */
-	WIMAX_GNL_VERSION = 00,
+	WIMAX_GNL_VERSION = 01,
 	/* Generic NetLink attributes */
 	WIMAX_GNL_ATTR_INVALID = 0x00,
 	WIMAX_GNL_ATTR_MAX = 10,
-- 
1.6.2.3

