From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbevf: Removed unneeded HW struct members
Date: Wed, 08 Sep 2010 00:36:04 -0700
Message-ID: <20100908073601.789.95153.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:44640
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758237Ab0IHHgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:36:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The VF has no flash and can only do memory mapped I/O.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/vf.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/ixgbevf/vf.h
index 94b750b..61f9dc8 100644
--- a/drivers/net/ixgbevf/vf.h
+++ b/drivers/net/ixgbevf/vf.h
@@ -124,8 +124,6 @@ struct ixgbe_hw {
 	void *back;
 
 	u8 __iomem *hw_addr;
-	u8 *flash_address;
-	unsigned long io_base;
 
 	struct ixgbe_mac_info mac;
 	struct ixgbe_mbx_info mbx;

