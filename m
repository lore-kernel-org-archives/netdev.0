From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] e1000e: cleanup comment in e1000_hash_mc_addr()
Date: Fri, 24 Feb 2012 21:49:57 -0800
Message-ID: <1330149000-25907-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1113 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341Ab2BYFuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 00:50:05 -0500
In-Reply-To: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove reference to non-existant function.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index f16a611..4130134 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -263,8 +263,7 @@ void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
  *  @mc_addr: pointer to a multicast address
  *
  *  Generates a multicast address hash value which is used to determine
- *  the multicast filter table array address and new table value.  See
- *  e1000_mta_set_generic()
+ *  the multicast filter table array address and new table value.
  **/
 static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 {
-- 
1.7.7.6
