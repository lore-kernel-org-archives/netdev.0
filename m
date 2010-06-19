From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH] Fix a typo in netlink.h
Date: Fri, 18 Jun 2010 21:29:53 -0700
Message-ID: <1276921793-24147-1-git-send-email-justinmattock@gmail.com>
Cc: netdev@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:60979 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab0FSEaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jun 2010 00:30:03 -0400
Received: by pxi12 with SMTP id 12so690150pxi.19
        for <netdev@vger.kernel.org>; Fri, 18 Jun 2010 21:30:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a typo in include/net/netlink.h 
should be finalize instead of finanlize

 Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 include/net/netlink.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 4fc05b5..f3b201d 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -35,7 +35,7 @@
  *   nlmsg_new()			create a new netlink message
  *   nlmsg_put()			add a netlink message to an skb
  *   nlmsg_put_answer()			callback based nlmsg_put()
- *   nlmsg_end()			finanlize netlink message
+ *   nlmsg_end()			finalize netlink message
  *   nlmsg_get_pos()			return current position in message
  *   nlmsg_trim()			trim part of message
  *   nlmsg_cancel()			cancel message construction
-- 
1.7.1.rc1.21.gf3bd6

