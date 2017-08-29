From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [PATCH net-next] bnxt_en: add a dummy definition for bnxt_vf_rep_get_fid()
Date: Tue, 29 Aug 2017 11:45:03 +0530
Message-ID: <1503987303-12392-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.232.149]:40340 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750758AbdH2GPI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 02:15:08 -0400
Received: from S30.dhcp.avagotech.net (unknown [10.192.238.30])
        by relay.smtp.broadcom.com (Postfix) with ESMTP id 153651A0707
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 23:15:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bnxt VF-reps are not compiled in (CONFIG_BNXT_SRIOV is off)
bnxt_tc.c needs a dummy definition of the routine bnxt_vf_rep_get_fid().

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 2ae7408fedfe ("bnxt_en: bnxt: add TC flower filter offload support")
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
index d8b5f89..7787cd24 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
@@ -80,5 +80,10 @@ static inline struct net_device *bnxt_get_vf_rep(struct bnxt *bp, u16 cfa_code)
 {
 	return NULL;
 }
+
+static inline u16 bnxt_vf_rep_get_fid(struct net_device *dev)
+{
+	return 0;
+}
 #endif /* CONFIG_BNXT_SRIOV */
 #endif /* BNXT_VFR_H */
-- 
2.7.4
