From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 02/10] ixgbe: fix IXGBE_MTQC values
Date: Fri, 10 Apr 2009 01:26:40 -0700
Message-ID: <20090410082639.14372.29299.stgit@localhost.localdomain>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:36231 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937784AbZDJQzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:55:09 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

IXGBE_MTQC_64VF was wrong and 32VF not defined at all.  This patch
corrects that.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_type.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 030ff0a..0d25036 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1553,7 +1553,8 @@
 #define IXGBE_MTQC_RT_ENA       0x1 /* DCB Enable */
 #define IXGBE_MTQC_VT_ENA       0x2 /* VMDQ2 Enable */
 #define IXGBE_MTQC_64Q_1PB      0x0 /* 64 queues 1 pack buffer */
-#define IXGBE_MTQC_64VF         0x8 /* 2 TX Queues per pool w/64VF's */
+#define IXGBE_MTQC_32VF         0x8 /* 4 TX Queues per pool w/32VF's */
+#define IXGBE_MTQC_64VF         0x4 /* 2 TX Queues per pool w/64VF's */
 #define IXGBE_MTQC_8TC_8TQ      0xC /* 8 TC if RT_ENA or 8 TQ if VT_ENA */
 
 /* Receive Descriptor bit definitions */

