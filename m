From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] i40e: Make struct i40e_stats const
Date: Sat, 29 Oct 2016 00:30:51 -0700
Message-ID: <1477726258-111563-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10260 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752440AbcJ2HbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:09 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Move some data to text

$ size drivers/net/ethernet/intel/i40e/i40e_ethtool.o*
   text	   data	    bss	    dec	    hex	filename
  25012	      0	     32	  25044	   61d4	drivers/net/ethernet/intel/i40e/i40e_ethtool.o.new
  22868	   2120	     32	  25020	   61bc	drivers/net/ethernet/intel/i40e/i40e_ethtool.o.old

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 92bc884..3a1f91e 100644
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
2.7.4
