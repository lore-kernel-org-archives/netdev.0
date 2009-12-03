From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/5] ixgbe: change default ring size
Date: Thu, 03 Dec 2009 13:33:07 -0800
Message-ID: <20091203213306.9291.86505.stgit@localhost.localdomain>
References: <20091203213221.9291.34218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:39188
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753291AbZLCVdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:33:21 -0500
In-Reply-To: <20091203213221.9291.34218.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

decrease the memory utilization of the tx / rx queue allocation
by changing the default ring size to 512 (from 1024).  At
1024 rx entries of 2KB each (from 4kB slab) with 16 queues
ixgbe was using 64 MB of memory per port, which is not
necessary.

Users can still change queue lengths with ethtool -k.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 7e35e97..91d80b7 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -51,11 +51,11 @@
 		__func__ , ## args)))
 
 /* TX/RX descriptor defines */
-#define IXGBE_DEFAULT_TXD		   1024
+#define IXGBE_DEFAULT_TXD		    512
 #define IXGBE_MAX_TXD			   4096
 #define IXGBE_MIN_TXD			     64
 
-#define IXGBE_DEFAULT_RXD		   1024
+#define IXGBE_DEFAULT_RXD		    512
 #define IXGBE_MAX_RXD			   4096
 #define IXGBE_MIN_RXD			     64
 

