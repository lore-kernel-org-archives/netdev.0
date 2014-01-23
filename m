From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] rtnetlink: add missing IFLA_BOND_AD_INFO_UNSPEC
Date: Thu, 23 Jan 2014 16:51:27 +0100
Message-ID: <1390492287-8368-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:61771 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbaAWPvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 10:51:32 -0500
Received: by mail-we0-f171.google.com with SMTP id w61so1385092wes.30
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 07:51:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/uapi/linux/if_link.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b8fb352..206f651 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -361,6 +361,7 @@ enum {
 #define IFLA_BOND_MAX	(__IFLA_BOND_MAX - 1)
 
 enum {
+	IFLA_BOND_AD_INFO_UNSPEC,
 	IFLA_BOND_AD_INFO_AGGREGATOR,
 	IFLA_BOND_AD_INFO_NUM_PORTS,
 	IFLA_BOND_AD_INFO_ACTOR_KEY,
-- 
1.8.3.1
