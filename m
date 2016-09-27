From: Joe Perches <joe@perches.com>
Subject: [PATCH] i40e: Make struct i40e_stats const
Date: Mon, 26 Sep 2016 20:17:01 -0700
Message-ID: <e5f6bf3aee230a9bcbca499a4288490afb6e4512.1474946199.git.joe@perches.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move some data to text

$ size drivers/net/ethernet/intel/i40e/i40e_ethtool.o*
   text	   data	    bss	    dec	    hex	filename
  25012	      0	     32	  25044	   61d4	drivers/net/ethernet/intel/i40e/i40e_ethtool.o.new
  22868	   2120	     32	  25020	   61bc	drivers/net/ethernet/intel/i40e/i40e_ethtool.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1835186b62c9..d8847a19dc6b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -104,7 +104,7 @@ static const struct i40e_stats i40e_gstrings_misc_stats[] = {
  * The PF_STATs are appended to the netdev stats only when ethtool -S
  * is queried on the base PF netdev, not on the VMDq or FCoE netdev.
  */
-static struct i40e_stats i40e_gstrings_stats[] = {
+static const struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("rx_bytes", stats.eth.rx_bytes),
 	I40E_PF_STAT("tx_bytes", stats.eth.tx_bytes),
 	I40E_PF_STAT("rx_unicast", stats.eth.rx_unicast),
-- 
2.10.0.rc2.1.g053435c
