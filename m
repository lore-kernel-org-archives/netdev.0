From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40evf: remove unnecessary __packed
Date: Wed, 26 Jul 2017 03:31:22 -0700
Message-ID: <20170726103123.76743-14-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:55881 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751708AbdGZKge (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:36:34 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>

This is similar to 'commit 9588397d24eec ("i40e: remove unnecessary
__packed")' to avoid unaligned access.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_osdep.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_osdep.h b/drivers/net/ethernet/intel/i40evf/i40e_osdep.h
index 5e314fd3c016..a90737786c34 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_osdep.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_osdep.h
@@ -54,7 +54,7 @@ struct i40e_dma_mem {
 	void *va;
 	dma_addr_t pa;
 	u32 size;
-} __packed;
+};
 
 #define i40e_allocate_dma_mem(h, m, unused, s, a) \
 	i40evf_allocate_dma_mem_d(h, m, s, a)
@@ -63,7 +63,7 @@ struct i40e_dma_mem {
 struct i40e_virt_mem {
 	void *va;
 	u32 size;
-} __packed;
+};
 #define i40e_allocate_virt_mem(h, m, s) i40evf_allocate_virt_mem_d(h, m, s)
 #define i40e_free_virt_mem(h, m) i40evf_free_virt_mem_d(h, m)
 
-- 
2.13.3
