From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 08/11] bnxt_en: Increase maximum supported MTU to 9500.
Date: Fri,  1 Jul 2016 18:46:26 -0400
Message-ID: <1467413189-29566-9-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36125 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbcGAWqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:51 -0400
Received: by mail-pa0-f54.google.com with SMTP id zl15so1646147pab.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:50 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara-v.volam@broadcom.com>

Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 28a5aee..9134268 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6049,7 +6049,7 @@ static int bnxt_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (new_mtu < 60 || new_mtu > 9000)
+	if (new_mtu < 60 || new_mtu > 9500)
 		return -EINVAL;
 
 	if (netif_running(dev))
-- 
1.8.3.1
