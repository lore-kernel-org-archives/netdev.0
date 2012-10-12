From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 1/2] net: add doc for in6_pton()
Date: Fri, 12 Oct 2012 15:06:16 +0800
Message-ID: <1350025577-792-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753395Ab2JLHG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 03:06:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not easy to use in6_pton() correctly without reading
its definition, so add some doc for it.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/utils.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/core/utils.c b/net/core/utils.c
index f5613d5..30f3879 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -161,6 +161,18 @@ out:
 }
 EXPORT_SYMBOL(in4_pton);
 
+/**
+ * in6_pton - convert an IPv6 address from literal to binary representation
+ * @src: the start of the IPv6 address string
+ * @srclen: the length of the string, -1 means strlen(src)
+ * @dst: the binary (u8[16] array) representation of the IPv6 address
+ * @delim: the delimiter of the IPv6 address in @src, -1 means no delimiter
+ * @end: A pointer to the end of the parsed string will be placed here
+ *
+ * Return one on success, return zero when any error occurs
+ * and @end will point to the end of the parsed string.
+ *
+ */
 int in6_pton(const char *src, int srclen,
 	     u8 *dst,
 	     int delim, const char **end)
-- 
1.7.7.6
