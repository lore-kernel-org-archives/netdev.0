From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 10/10] wimax: a new API call was added, increment minor protocol version number
Date: Wed, 27 May 2009 18:05:15 -0700
Message-ID: <6c88e32ef9c71ad369892290da00820952cfc402.1243472510.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
 <e9de4b9426eeeddf56110425cfd88e43828e7146.1243472510.git.inaky@linux.intel.com>
 <22d4458f609ba31f1382e25844125e421dcd4163.1243472510.git.inaky@linux.intel.com>
 <05962df1398ad316feb1e20160b7502731bebc97.1243472510.git.inaky@linux.intel.com>
 <ba98dde3cde9f5910789b32852c692fc8cd0a4aa.1243472510.git.inaky@linux.intel.com>
 <74bd64a25b220d21e50c7c9a85f26ff6617b3728.1243472510.git.inaky@linux.intel.com>
 <f3aea79091a4fc501235f2e743cc073ebd962934.1243472510.git.inaky@linux.intel.com>
 <d791bac79c5e9840a3e5317a4bb79acafde911f9.1243472510.git.inaky@linux.intel.com>
 <4d58364611c66a20ea1e28223b8f638fd2e35981.1243472510.git.inaky@linux.intel.com>
 <5b274b76ee31802e4376f44bc96a4b3bc9f8b918.1243472510.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:11221 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757646AbZE1BFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 21:05:49 -0400
In-Reply-To: <5b274b76ee31802e4376f44bc96a4b3bc9f8b918.1243472510.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243472509.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
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
index c750f42..b40298a 100644
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

