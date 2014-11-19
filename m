From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40evf: update header comments
Date: Tue, 18 Nov 2014 20:10:52 -0800
Message-ID: <1416370256-16834-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41461 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbaKSELH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 23:11:07 -0500
In-Reply-To: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

No code changes. Update comments to match actual function declarations.

Change-ID: Ib830d2f154ee917a104955c0914267fc98f3d2c8
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 876411c..b2cd9ea 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -621,7 +621,7 @@ static u32 i40evf_get_rxfh_indir_size(struct net_device *netdev)
  * i40evf_get_rxfh - get the rx flow hash indirection table
  * @netdev: network interface device structure
  * @indir: indirection table
- * @key: hash key (will be %NULL until get_rxfh_key_size is implemented)
+ * @key: hash key
  *
  * Reads the indirection table directly from the hardware. Always returns 0.
  **/
@@ -646,7 +646,7 @@ static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
  * i40evf_set_rxfh - set the rx flow hash indirection table
  * @netdev: network interface device structure
  * @indir: indirection table
- * @key: hash key (will be %NULL until get_rxfh_key_size is implemented)
+ * @key: hash key
  *
  * Returns -EINVAL if the table specifies an inavlid queue id, otherwise
  * returns 0 after programming the table.
-- 
1.9.3
