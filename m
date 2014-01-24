From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] rtnetlink: remove IFLA_BOND_SLAVE definition
Date: Fri, 24 Jan 2014 08:39:16 +0100
Message-ID: <1390549156-1697-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevich@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:41058 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaAXHjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 02:39:20 -0500
Received: by mail-ea0-f182.google.com with SMTP id r15so795312ead.41
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 23:39:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in net-next only, for couple of days. Not used anymore, and never
should have been. So just remove it and pretend it was never there.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/uapi/linux/if_link.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 206f651..16410b6 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -144,7 +144,6 @@ enum {
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
-	IFLA_BOND_SLAVE,
 	__IFLA_MAX
 };
 
-- 
1.8.3.1
