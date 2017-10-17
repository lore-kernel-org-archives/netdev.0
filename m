From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: fix comment typo
Date: Tue, 17 Oct 2017 11:21:10 -0700
Message-ID: <20171017182119.71989-7-jeffrey.t.kirsher@intel.com>
References: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:48881 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934565AbdJQSVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:42 -0400
In-Reply-To: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Someone forgot a word in this comment and it's confusing without it.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index a137675c1426..e40fb559dacb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -516,8 +516,8 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 	}
 
 	/* Now that we've worked out everything that could be supported by the
-	 * current PHY type, get what is supported by the NVM and them to
-	 * get what is truly supported
+	 * current PHY type, get what is supported by the NVM and intersect
+	 * them to get what is truly supported
 	 */
 	i40e_phy_type_to_ethtool(pf, &e_supported,
 				 &e_advertising);
-- 
2.14.2
