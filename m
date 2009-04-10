From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 04/10] ixgbe: add define to support 82599 64 IVAR registers
Date: Fri, 10 Apr 2009 01:27:19 -0700
Message-ID: <20090410082719.14372.78083.stgit@localhost.localdomain>
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
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:34011
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S938450AbZDJQzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:55:49 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

82599 supports 64 IVAR registers this patch adds a define to
allow us to access them.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_type.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 50285c2..96e15d0 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1150,6 +1150,7 @@
 
 /* Interrupt Vector Allocation Registers */
 #define IXGBE_IVAR_REG_NUM      25
+#define IXGBE_IVAR_REG_NUM_82599       64
 #define IXGBE_IVAR_TXRX_ENTRY   96
 #define IXGBE_IVAR_RX_ENTRY     64
 #define IXGBE_IVAR_RX_QUEUE(_i)    (0 + (_i))

