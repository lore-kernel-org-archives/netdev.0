From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbevf: declare functions as static
Date: Tue, 05 Oct 2010 16:11:30 -0700
Message-ID: <20101005231030.24410.47680.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Greg Rose <greg.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:59077
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756357Ab0JEXLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 19:11:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Following patch fixes warnings reported by `make namespacecheck`

Reported by Stephen Hemminger

CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Greg Rose <greg.v.rose@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/mbx.c |    2 +-
 drivers/net/ixgbevf/mbx.h |    2 --
 drivers/net/ixgbevf/vf.c  |    2 +-
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbevf/mbx.c b/drivers/net/ixgbevf/mbx.c
index b814350..84ac486 100644
--- a/drivers/net/ixgbevf/mbx.c
+++ b/drivers/net/ixgbevf/mbx.c
@@ -308,7 +308,7 @@ out_no_read:
  *
  *  Initializes the hw->mbx struct to correct values for vf mailbox
  */
-s32 ixgbevf_init_mbx_params_vf(struct ixgbe_hw *hw)
+static s32 ixgbevf_init_mbx_params_vf(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 
diff --git a/drivers/net/ixgbevf/mbx.h b/drivers/net/ixgbevf/mbx.h
index 1b0e0bf..8c063be 100644
--- a/drivers/net/ixgbevf/mbx.h
+++ b/drivers/net/ixgbevf/mbx.h
@@ -95,6 +95,4 @@
 /* forward declaration of the HW struct */
 struct ixgbe_hw;
 
-s32 ixgbevf_init_mbx_params_vf(struct ixgbe_hw *);
-
 #endif /* _IXGBE_MBX_H_ */
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
index f6f9299..bfe42c1 100644
--- a/drivers/net/ixgbevf/vf.c
+++ b/drivers/net/ixgbevf/vf.c
@@ -368,7 +368,7 @@ static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 	return 0;
 }
 
-struct ixgbe_mac_operations ixgbevf_mac_ops = {
+static struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.init_hw             = ixgbevf_init_hw_vf,
 	.reset_hw            = ixgbevf_reset_hw_vf,
 	.start_hw            = ixgbevf_start_hw_vf,

