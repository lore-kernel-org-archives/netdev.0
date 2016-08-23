From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] igb: fix non static symbol warning
Date: Tue, 23 Aug 2016 15:08:09 +0000
Message-ID: <1471964889-511-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36188 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbcHWPIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:08:34 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so8428960pfg.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 08:08:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/ethernet/intel/igb/igb_ethtool.c:2707:5: warning:
 symbol 'igb_rxnfc_write_vlan_prio_filter' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
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
