From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/5] ixgbe: remove ixgbe_napi_add/del_all
	references
Date: Wed, 06 May 2009 13:44:07 -0700
Message-ID: <20090506204406.18071.32536.stgit@localhost.localdomain>
References: <20090506204317.18071.96421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:54512
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932175AbZEFUoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:44:25 -0400
In-Reply-To: <20090506204317.18071.96421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There were still some references to napi_add/del_all left after the dynamic
vector allocation patch.  This patch removes those references since the
ixgbe_napi_add/del_all calls are no longer needed as the napi struct is
added when the vector is created, and deleted when the vector is freed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 61cb415..d743d0e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -370,8 +370,6 @@ extern void ixgbe_free_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *)
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
-void ixgbe_napi_add_all(struct ixgbe_adapter *adapter);
-void ixgbe_napi_del_all(struct ixgbe_adapter *adapter);
 extern void ixgbe_write_eitr(struct ixgbe_adapter *, int, u32);
 
 #endif /* _IXGBE_H_ */

