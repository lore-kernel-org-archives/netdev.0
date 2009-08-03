From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 3/5] nl802154: make ieee802154_policy constant
Date: Tue,  4 Aug 2009 03:11:39 +0400
Message-ID: <1249341101-11593-2-git-send-email-dbaryshkov@gmail.com>
References: <1249339902-10613-2-git-send-email-dbaryshkov@gmail.com>
 <1249341101-11593-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:65265 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbZHCXMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 19:12:07 -0400
Received: by bwz19 with SMTP id 19so2748734bwz.37
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 16:12:07 -0700 (PDT)
In-Reply-To: <1249341101-11593-1-git-send-email-dbaryshkov@gmail.com>
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

