From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: Fix warning reported by kbuild test robot.
Date: Fri, 6 Sep 2013 18:04:32 -0400
Message-ID: <1378505072-7879-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:39164 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751709Ab3IFWdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 18:33:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c: In function 'qlcnic_handle_fw_message':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:922:4: warning: overflow in implicit constant conversion [-Woverflow]

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 88349b8..81bf836 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -430,7 +430,7 @@ struct qlcnic_hardware_context {
 	u8 diag_test;
 	u8 num_msix;
 	u8 nic_mode;
-	char diag_cnt;
+	int diag_cnt;
 
 	u16 max_uc_count;
 	u16 port_type;
-- 
1.7.1
