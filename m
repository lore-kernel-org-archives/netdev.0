From: vibi sreenivasan <vibi_sreenivasan@cms.com>
Subject: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Tue, 11 Aug 2009 15:37:03 +0530
Message-ID: <1249985224.13065.11.camel@HunTEr>
Reply-To: vibi_sreenivasan@cms.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Thomas Graf <tgraf@suug.ch>,
	linux-next <linux-next@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.cms.com ([203.124.163.53]:16959 "EHLO cms.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752336AbZHKNNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2009 09:13:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/netlink/genetlink.c: In function `genl_register_mc_group':
net/netlink/genetlink.c:139: warning: 'err' might be used uninitialized in this function

Signed-off-by: vibi sreenivasan <vibi_sreenivasan@cms.com>
---
 net/netlink/genetlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 575c643..66f6ba0 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *family,
 {
        int id;
        unsigned long *new_groups;
-       int err;
+       int err = 0;
 
        BUG_ON(grp->name[0] == '\0');
 
-- 
1.6.3.3




