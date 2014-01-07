From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Reduce range of interrupt reg in reg test
Date: Tue,  7 Jan 2014 01:32:22 -0800
Message-ID: <1389087149-27962-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389087149-27962-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Kamil Krawczyk <kamil.krawczyk@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6793 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852AbaAGJch (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 04:32:37 -0500
In-Reply-To: <1389087149-27962-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Use a smaller range of test registers in MFP mode as there are fewer
resources than when in SFP mode.

Change-Id: I08424890c3f57b5dde5ee99e99724ce252e0875a
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_diag.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_diag.c b/drivers/net/ethernet/intel/i40e/i40e_diag.c
index 98c1ef5..6a1657e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_diag.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_diag.c
@@ -70,9 +70,9 @@ struct i40e_diag_reg_test_info i40e_reg_list[] = {
 	/* offset               mask         elements   stride */
 	{I40E_QTX_CTL(0),       0x0000FFBF,   4, I40E_QTX_CTL(1) - I40E_QTX_CTL(0)},
 	{I40E_PFINT_ITR0(0),    0x00000FFF,   3, I40E_PFINT_ITR0(1) - I40E_PFINT_ITR0(0)},
-	{I40E_PFINT_ITRN(0, 0), 0x00000FFF,  64, I40E_PFINT_ITRN(0, 1) - I40E_PFINT_ITRN(0, 0)},
-	{I40E_PFINT_ITRN(1, 0), 0x00000FFF,  64, I40E_PFINT_ITRN(1, 1) - I40E_PFINT_ITRN(1, 0)},
-	{I40E_PFINT_ITRN(2, 0), 0x00000FFF,  64, I40E_PFINT_ITRN(2, 1) - I40E_PFINT_ITRN(2, 0)},
+	{I40E_PFINT_ITRN(0, 0), 0x00000FFF,   8, I40E_PFINT_ITRN(0, 1) - I40E_PFINT_ITRN(0, 0)},
+	{I40E_PFINT_ITRN(1, 0), 0x00000FFF,   8, I40E_PFINT_ITRN(1, 1) - I40E_PFINT_ITRN(1, 0)},
+	{I40E_PFINT_ITRN(2, 0), 0x00000FFF,   8, I40E_PFINT_ITRN(2, 1) - I40E_PFINT_ITRN(2, 0)},
 	{I40E_PFINT_STAT_CTL0,  0x0000000C,   1, 0},
 	{I40E_PFINT_LNKLST0,    0x00001FFF,   1, 0},
 	{I40E_PFINT_LNKLSTN(0), 0x000007FF,  64, I40E_PFINT_LNKLSTN(1) - I40E_PFINT_LNKLSTN(0)},
-- 
1.8.3.1
