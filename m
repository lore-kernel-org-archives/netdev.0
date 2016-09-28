From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 1/4] igb: fix non static symbol warning
Date: Tue, 27 Sep 2016 19:04:58 -0700
Message-ID: <1475028301-122700-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1475028301-122700-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:12751 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755074AbcI1CFD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 22:05:03 -0400
In-Reply-To: <1475028301-122700-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/ethernet/intel/igb/igb_ethtool.c:2707:5: warning:
 symbol 'igb_rxnfc_write_vlan_prio_filter' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 0c33eca..737b664 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2704,8 +2704,8 @@ static int igb_rxnfc_write_etype_filter(struct igb_adapter *adapter,
 	return 0;
 }
 
-int igb_rxnfc_write_vlan_prio_filter(struct igb_adapter *adapter,
-				     struct igb_nfc_filter *input)
+static int igb_rxnfc_write_vlan_prio_filter(struct igb_adapter *adapter,
+					    struct igb_nfc_filter *input)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u8 vlan_priority;
-- 
2.7.4
