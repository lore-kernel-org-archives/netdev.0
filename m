From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 03/10] nl802154: make ieee802154_policy constant
Date: Fri,  7 Aug 2009 16:58:38 +0400
Message-ID: <1249649925-11996-4-git-send-email-dbaryshkov@gmail.com>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
 <1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
 <1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:61187 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757848AbZHGM7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 08:59:23 -0400
Received: by mail-ew0-f214.google.com with SMTP id 10so1509822ewy.37
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 05:59:24 -0700 (PDT)
In-Reply-To: <1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 include/linux/nl802154.h   |    2 +-
 net/ieee802154/nl_policy.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 2cda00c..266dd96 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -69,7 +69,7 @@ enum {
 
 #define IEEE802154_ATTR_MAX (__IEEE802154_ATTR_MAX - 1)
 
-extern struct nla_policy ieee802154_policy[];
+extern const struct nla_policy ieee802154_policy[];
 
 /* commands */
 /* REQ should be responded with CONF
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index c7d71d1..83cb4cc 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -24,7 +24,7 @@
 
 #define NLA_HW_ADDR NLA_U64
 
-struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
+const struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_DEV_NAME] = { .type = NLA_STRING, },
 	[IEEE802154_ATTR_DEV_INDEX] = { .type = NLA_U32, },
 
@@ -50,3 +50,4 @@ struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] = {
 	[IEEE802154_ATTR_DURATION] = { .type = NLA_U8, },
 	[IEEE802154_ATTR_ED_LIST] = { .len = 27 },
 };
+
-- 
1.6.3.3

