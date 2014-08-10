From: Andreas Ruprecht <rupran@einserver.de>
Subject: [PATCH] net: ethernet: qlogic: qlcnic: Remove duplicate object file from Makefile
Date: Sun, 10 Aug 2014 21:40:48 +0200
Message-ID: <1407699648-3500-1-git-send-email-rupran@einserver.de>
Cc: Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	Andreas Ruprecht <rupran@einserver.de>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:64700 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaHJTm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 15:42:57 -0400
Received: by mail-wg0-f42.google.com with SMTP id l18so7559415wgh.13
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2014 12:42:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the Makefile, qlcnic_minidump.o is included twice in the list of
object files linked into qlcnic.o.

This change removes the superfluous include.

Signed-off-by: Andreas Ruprecht <rupran@einserver.de>
---
 drivers/net/ethernet/qlogic/qlcnic/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/Makefile b/drivers/net/ethernet/qlogic/qlcnic/Makefile
index a848d29..3c2c2c7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/Makefile
+++ b/drivers/net/ethernet/qlogic/qlcnic/Makefile
@@ -8,7 +8,7 @@ qlcnic-y := qlcnic_hw.o qlcnic_main.o qlcnic_init.o \
 	qlcnic_ethtool.o qlcnic_ctx.o qlcnic_io.o \
 	qlcnic_sysfs.o qlcnic_minidump.o qlcnic_83xx_hw.o \
 	qlcnic_83xx_init.o qlcnic_83xx_vnic.o \
-	qlcnic_minidump.o qlcnic_sriov_common.o
+	qlcnic_sriov_common.o
 
 qlcnic-$(CONFIG_QLCNIC_SRIOV) += qlcnic_sriov_pf.o
 
-- 
1.9.1
