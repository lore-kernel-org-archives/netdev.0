From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [NET] Add constant for FCS/CRC length (frame check sequence)
Date: Tue, 15 May 2007 15:29:16 -0700
Message-ID: <20070515222916.9404.51955.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke@foo-projects.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50610 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757855AbXEOW3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 18:29:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>

About a dozen drivers that have some form of crc checksumming or offloading
use this constant, warranting a global define for it.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 include/linux/if_ether.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 1db774c..3213f6f 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -33,6 +33,7 @@
 #define ETH_ZLEN	60		/* Min. octets in frame sans FCS */
 #define ETH_DATA_LEN	1500		/* Max. octets in payload	 */
 #define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
+#define ETH_FCS_LEN	4		/* Octets in the FCS		 */
 
 /*
  *	These are the defined Ethernet Protocol ID's.
