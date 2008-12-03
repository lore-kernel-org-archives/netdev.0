From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next 2/2]ixgbe: function comment typo
Date: Wed, 03 Dec 2008 20:57:45 +0800
Message-ID: <49368249.1020608@cn.fujitsu.com>
References: <49353915.4060002@cn.fujitsu.com> <20081202.150623.70107608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61215 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752019AbYLCM5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 07:57:53 -0500
In-Reply-To: <20081202.150623.70107608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems the ixgbe's code was copied from e1000.
The comment talks about something not exist.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e014a73..a7aa892 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2521,8 +2521,7 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
  * @adapter: board private structure to initialize
  *
  * We allocate one ring per queue at run-time since we don't know the
- * number of queues at compile-time.  The polling_netdev array is
- * intended for Multiqueue, but should work fine with a single queue.
+ * number of queues at compile-time.
  **/
 static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 {
-- 
1.5.3.4


