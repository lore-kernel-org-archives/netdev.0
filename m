From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/2] net: add doc for in4_pton()
Date: Fri, 12 Oct 2012 15:06:17 +0800
Message-ID: <1350025577-792-2-git-send-email-amwang@redhat.com>
References: <1350025577-792-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756061Ab2JLHGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 03:06:30 -0400
In-Reply-To: <1350025577-792-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not easy to use in4_pton() correctly without reading
its definition, so add some doc for it.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/utils.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/core/utils.c b/net/core/utils.c
index 30f3879..e3487e46 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -107,6 +107,18 @@ static inline int xdigit2bin(char c, int delim)
 	return IN6PTON_UNKNOWN;
 }
 
+/**
+ * in4_pton - convert an IPv4 address from literal to binary representation
+ * @src: the start of the IPv4 address string
+ * @srclen: the length of the string, -1 means strlen(src)
+ * @dst: the binary (u8[4] array) representation of the IPv4 address
+ * @delim: the delimiter of the IPv4 address in @src, -1 means no delimiter
+ * @end: A pointer to the end of the parsed string will be placed here
+ *
+ * Return one on success, return zero when any error occurs
+ * and @end will point to the end of the parsed string.
+ *
+ */
 int in4_pton(const char *src, int srclen,
 	     u8 *dst,
 	     int delim, const char **end)
-- 
1.7.7.6
