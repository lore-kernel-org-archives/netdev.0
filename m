From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bnx2x: fix sparse warning
Date: Tue, 14 Jan 2014 10:14:11 -0800
Message-ID: <20140114101411.0ac2452e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:35172 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbaANSOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 13:14:14 -0500
Received: by mail-pb0-f50.google.com with SMTP id rq2so935071pbb.37
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 10:14:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix new sparse warning about function declared static.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c	2014-01-14 09:46:20.701651762 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c	2014-01-14 09:57:31.562110348 -0800
@@ -8602,8 +8602,8 @@ static void bnx2x_set_limiting_mode(stru
 	}
 }
 
-int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
-			       struct link_params *params)
+static int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
+				      struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 edc_mode;
