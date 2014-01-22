From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/6] rtnetlink: remove IFLA_SLAVES definition
Date: Wed, 22 Jan 2014 11:43:55 +0100
Message-ID: <1390387435-23918-1-git-send-email-jiri@resnulli.us>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:56592 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbaAVKoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 05:44:02 -0500
Received: by mail-ea0-f173.google.com with SMTP id d10so1639341eaj.18
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 02:44:00 -0800 (PST)
In-Reply-To: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not used anymore, and never should be.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/uapi/linux/if_link.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b8fb352..ed7b2f8 100644
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
