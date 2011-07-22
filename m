From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 01/10] bna: Print Driver Version
Date: Fri, 22 Jul 2011 11:07:40 -0700
Message-ID: <1311358069-32067-2-git-send-email-rmody@brocade.com>
References: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37591 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751578Ab1GVSIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 14:08:11 -0400
In-Reply-To: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Print the dirver version when module is loaded.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index fa997bf..e88f024 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -3253,7 +3253,8 @@ bnad_module_init(void)
 {
 	int err;
 
-	pr_info("Brocade 10G Ethernet driver\n");
+	pr_info("Brocade 10G Ethernet driver - version: %s\n",
+			BNAD_VERSION);
 
 	bfa_nw_ioc_auto_recover(bnad_ioc_auto_recover);
 
-- 
1.7.1

