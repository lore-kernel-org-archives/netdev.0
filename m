From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Fix function header
Date: Mon,  9 Feb 2015 02:43:58 -0800
Message-ID: <1423478641-3138-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35313 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760623AbbBIKoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:06 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

s/enable/disable

Change-ID: Ic0572a6c59d03e05a0a35d2e2e9d532e0512638d
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1923a0b..cbe281b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2940,7 +2940,7 @@ void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 /**
  * i40e_irq_dynamic_disable - Disable default interrupt generation settings
  * @vsi: pointer to a vsi
- * @vector: enable a particular Hw Interrupt vector
+ * @vector: disable a particular Hw Interrupt vector
  **/
 void i40e_irq_dynamic_disable(struct i40e_vsi *vsi, int vector)
 {
-- 
1.9.3
