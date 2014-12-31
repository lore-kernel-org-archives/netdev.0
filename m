From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: intel: i40e: i40e_fcoe.c:  Remove unused function
Date: Wed, 31 Dec 2014 17:48:57 +0100
Message-ID: <1420044537-21077-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function i40e_rx_is_fip() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 5d01db1..20a5bfa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -39,15 +39,6 @@
 #include "i40e_fcoe.h"
 
 /**
- * i40e_rx_is_fip - returns true if the rx packet type is FIP
- * @ptype: the packet type field from rx descriptor write-back
- **/
-static inline bool i40e_rx_is_fip(u16 ptype)
-{
-	return ptype == I40E_RX_PTYPE_L2_FIP_PAY2;
-}
-
-/**
  * i40e_rx_is_fcoe - returns true if the rx packet type is FCoE
  * @ptype: the packet type field from rx descriptor write-back
  **/
-- 
1.7.10.4
