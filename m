From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 03/10] ixgbe: add support for addition VT_CTL defines
Date: Fri, 10 Apr 2009 01:27:00 -0700
Message-ID: <20090410082659.14372.80723.stgit@localhost.localdomain>
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
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:49975
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S938032AbZDJQz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:55:29 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

These defines allow for definition of target pool for packets that
pass L2 filtering but didn't pass any of the pool filters.  They are
needed to reset the default pool.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_type.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 0d25036..50285c2 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -958,6 +958,8 @@
 #define IXGBE_VT_CTL_DIS_DEFPL  0x20000000 /* disable default pool */
 #define IXGBE_VT_CTL_REPLEN     0x40000000 /* replication enabled */
 #define IXGBE_VT_CTL_VT_ENABLE  0x00000001  /* Enable VT Mode */
+#define IXGBE_VT_CTL_POOL_SHIFT 7
+#define IXGBE_VT_CTL_POOL_MASK  (0x3F << IXGBE_VT_CTL_POOL_SHIFT)
 
 /* VMOLR bitmasks */
 #define IXGBE_VMOLR_AUPE        0x01000000 /* accept untagged packets */

