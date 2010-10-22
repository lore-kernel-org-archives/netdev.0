From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 2/3] vmxnet3: annotate hwaddr members as __iomem pointers
Date: Thu, 21 Oct 2010 21:05:33 -0700
Message-ID: <1287720334-15469-2-git-send-email-harvey.harrison@gmail.com>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:54624 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab0JVEFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 00:05:41 -0400
Received: by pzk3 with SMTP id 3so59022pzk.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 21:05:41 -0700 (PDT)
In-Reply-To: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/vmxnet3/vmxnet3_int.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 46aee6d..8a2f471 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -301,8 +301,8 @@ struct vmxnet3_adapter {
 	struct net_device              *netdev;
 	struct pci_dev                 *pdev;
 
-	u8				*hw_addr0; /* for BAR 0 */
-	u8				*hw_addr1; /* for BAR 1 */
+	u8			__iomem *hw_addr0; /* for BAR 0 */
+	u8			__iomem *hw_addr1; /* for BAR 1 */
 
 	/* feature control */
 	bool				rxcsum;
-- 
1.7.1

