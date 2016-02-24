From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/6] qed: add MODULE_FIRMWARE()
Date: Wed, 24 Feb 2016 16:52:48 +0200
Message-ID: <1456325570-1514-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:55135 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753906AbcBXOxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 09:53:09 -0500
In-Reply-To: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Module is using a binary firmware file and so should be marked as such.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 593f887..08cd92d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -45,6 +45,8 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 #define QED_FW_FILE_NAME	\
 	"qed/qed_init_values_zipped-" FW_FILE_VERSION ".bin"
 
+MODULE_FIRMWARE(QED_FW_FILE_NAME);
+
 static int __init qed_init(void)
 {
 	pr_notice("qed_init called\n");
-- 
1.9.3
