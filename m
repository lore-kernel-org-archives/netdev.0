From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 45/45] bna: Driver Version changed to 3.0.2.0
Date: Mon, 18 Jul 2011 01:23:05 -0700
Message-ID: <1310977385-5268-35-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37859 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755012Ab1GRIZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:33 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |    3 ++-
 drivers/net/bna/bnad.h |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 68cd328..218ef48 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -3519,7 +3519,8 @@ bnad_module_init(void)
 {
 	int err;
 
-	pr_info("Brocade 10G Ethernet driver %s\n", BNAD_VERSION);
+	pr_info("Brocade 10G Ethernet driver - version: %s\n",
+			BNAD_VERSION);
 
 	bfa_nw_ioc_auto_recover(bnad_ioc_auto_recover);
 
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 5563bf9..f1646ad 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -69,7 +69,7 @@ struct bnad_rx_ctrl {
 #define BNAD_NAME			"bna"
 #define BNAD_NAME_LEN			64
 
-#define BNAD_VERSION			"2.3.2.3"
+#define BNAD_VERSION			"3.0.2.0"
 
 #define BNAD_MAILBOX_MSIX_INDEX		0
 #define BNAD_MAILBOX_MSIX_VECTORS	1
-- 
1.7.1

