From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: restrict diag test length
Date: Fri,  6 Dec 2013 00:06:27 -0800
Message-ID: <1386317188-13944-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42213 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753325Ab3LFIGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:37 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

The diagnostics test needs some slightly different limits
in order to succeed.

Change-Id: Ia1c49148af92fa4be20778a819f69350381bf865
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_diag.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_diag.c b/drivers/net/ethernet/intel/i40e/i40e_diag.c
index de25514..dc6c41f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_diag.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_diag.c
@@ -68,16 +68,16 @@ static i40e_status i40e_diag_reg_pattern_test(struct i40e_hw *hw,
 
 struct i40e_diag_reg_test_info i40e_reg_list[] = {
 	/* offset               mask         elements   stride */
-	{I40E_QTX_CTL(0),       0x0000FFBF,  64, I40E_QTX_CTL(1) - I40E_QTX_CTL(0)},
+	{I40E_QTX_CTL(0),       0x0000FFBF,   4, I40E_QTX_CTL(1) - I40E_QTX_CTL(0)},
 	{I40E_PFINT_ITR0(0),    0x00000FFF,   3, I40E_PFINT_ITR0(1) - I40E_PFINT_ITR0(0)},
 	{I40E_PFINT_ITRN(0, 0), 0x00000FFF,  64, I40E_PFINT_ITRN(0, 1) - I40E_PFINT_ITRN(0, 0)},
 	{I40E_PFINT_ITRN(1, 0), 0x00000FFF,  64, I40E_PFINT_ITRN(1, 1) - I40E_PFINT_ITRN(1, 0)},
 	{I40E_PFINT_ITRN(2, 0), 0x00000FFF,  64, I40E_PFINT_ITRN(2, 1) - I40E_PFINT_ITRN(2, 0)},
 	{I40E_PFINT_STAT_CTL0,  0x0000000C,   1, 0},
 	{I40E_PFINT_LNKLST0,    0x00001FFF,   1, 0},
-	{I40E_PFINT_LNKLSTN(0), 0x000007FF, 511, I40E_PFINT_LNKLSTN(1) - I40E_PFINT_LNKLSTN(0)},
-	{I40E_QINT_TQCTL(0),    0x000000FF, I40E_QINT_TQCTL_MAX_INDEX + 1, I40E_QINT_TQCTL(1) - I40E_QINT_TQCTL(0)},
-	{I40E_QINT_RQCTL(0),    0x000000FF, I40E_QINT_RQCTL_MAX_INDEX + 1, I40E_QINT_RQCTL(1) - I40E_QINT_RQCTL(0)},
+	{I40E_PFINT_LNKLSTN(0), 0x000007FF,  64, I40E_PFINT_LNKLSTN(1) - I40E_PFINT_LNKLSTN(0)},
+	{I40E_QINT_TQCTL(0),    0x000000FF,  64, I40E_QINT_TQCTL(1) - I40E_QINT_TQCTL(0)},
+	{I40E_QINT_RQCTL(0),    0x000000FF,  64, I40E_QINT_RQCTL(1) - I40E_QINT_RQCTL(0)},
 	{I40E_PFINT_ICR0_ENA,   0xF7F20000,   1, 0},
 	{ 0 }
 };
-- 
1.8.3.1
