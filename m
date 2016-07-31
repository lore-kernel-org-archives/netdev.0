From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: qlcnic: avoid superfluous assignement
Date: Sun, 31 Jul 2016 12:07:37 +0200
Message-ID: <1469959657-1342-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Dept-GELinuxNICDev@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:63832 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753158AbcGaKHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 06:07:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assigning NULL to parmeter dcb has no effect outside of the
inlined function.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
index 9777e57..f4aa633 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
@@ -45,7 +45,6 @@ struct qlcnic_dcb {
 static inline void qlcnic_clear_dcb_ops(struct qlcnic_dcb *dcb)
 {
 	kfree(dcb);
-	dcb = NULL;
 }
 
 static inline int qlcnic_dcb_get_hw_capability(struct qlcnic_dcb *dcb)
-- 
2.8.1
