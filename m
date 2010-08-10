From: sjur.brandeland@stericsson.com
Subject: [PATCH 1/2] caif: Bugfix - Increase default headroom size for control
 channel.
Date: Tue, 10 Aug 2010 19:36:46 +0200
Message-ID: <1281461807-17408-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: sjurbren@gmail.com, netdev@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:37416 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932302Ab0HJShr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 14:37:47 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L6Y00FGO69EOW90@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Tue, 10 Aug 2010 19:36:50 +0200 (CEST)
Received: from localhost.localdomain ([84.49.77.68]) by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L6Y00LT669DLCT0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Tue, 10 Aug 2010 19:36:50 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Headroom size for control channel must be at least 48 bytes in some scenarios.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfpkt_skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 01f238f..c49a669 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -9,7 +9,7 @@
 #include <linux/hardirq.h>
 #include <net/caif/cfpkt.h>
 
-#define PKT_PREFIX  16
+#define PKT_PREFIX  48
 #define PKT_POSTFIX 2
 #define PKT_LEN_WHEN_EXTENDING 128
 #define PKT_ERROR(pkt, errmsg) do {	   \
-- 
1.6.3.3

