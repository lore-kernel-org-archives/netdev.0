From: Kyle McMartin <kyle@mcmartin.ca>
Subject: [PATCH] rds: only for x86 or 64-bit at the moment...
Date: Tue, 31 Mar 2009 17:06:09 -0400
Message-ID: <20090331210609.GD25513@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42226 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285AbZCaVGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 17:06:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@redhat.com>

set_64bit doesn't exist anywhere but x86 right now, so either
BITS_PER_LONG needs to be 64, or we need to be on x86, in order to
build this module.

Signed-off-by: Kyle McMartin <kyle@redhat.com>
---
diff --git a/net/rds/Kconfig b/net/rds/Kconfig
index 796773b..84df275 100644
--- a/net/rds/Kconfig
+++ b/net/rds/Kconfig
@@ -1,7 +1,7 @@
 
 config RDS
 	tristate "Reliable Datagram Sockets (RDS) (EXPERIMENTAL)"
-	depends on INET && INFINIBAND_IPOIB && EXPERIMENTAL
+	depends on INET && INFINIBAND_IPOIB && EXPERIMENTAL && (64BIT || X86)
 	depends on INFINIBAND && INFINIBAND_ADDR_TRANS
 	---help---
 	  RDS provides reliable, sequenced delivery of datagrams
