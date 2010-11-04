From: Nelson Elhage <nelhage@ksplice.com>
Subject: [PATCH 1/2] netlink: Make nlmsg_find_attr take a const nlmsghdr*.
Date: Wed,  3 Nov 2010 22:35:40 -0400
Message-ID: <1288838141-17871-1-git-send-email-nelhage@ksplice.com>
Cc: Nelson Elhage <nelhage@ksplice.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-8.MIT.EDU ([18.7.68.37]:49115 "EHLO
	dmz-mailsec-scanner-8.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752125Ab0KDCgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 22:36:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will let us use it on a nlmsghdr stored inside a netlink_callback.

Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
---
 include/net/netlink.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index f3b201d..9801c55 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -384,7 +384,7 @@ static inline int nlmsg_parse(const struct nlmsghdr *nlh, int hdrlen,
  *
  * Returns the first attribute which matches the specified type.
  */
-static inline struct nlattr *nlmsg_find_attr(struct nlmsghdr *nlh,
+static inline struct nlattr *nlmsg_find_attr(const struct nlmsghdr *nlh,
 					     int hdrlen, int attrtype)
 {
 	return nla_find(nlmsg_attrdata(nlh, hdrlen),
-- 
1.7.1.31.g6297e

