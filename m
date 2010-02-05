From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 02/13] net: add a wrapper sk_entry()
Date: Fri, 05 Feb 2010 09:45:10 +0800
Message-ID: <4B6B7826.9010003@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61362 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756973Ab0BEBoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 20:44:55 -0500
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 include/net/sock.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3f1a480..c8d4000 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -317,6 +317,11 @@ struct sock {
 /*
  * Hashed lists helper routines
  */
+static inline struct sock *sk_entry(const struct hlist_node *node)
+{
+	return hlist_entry(node, struct sock, sk_node);
+}
+
 static inline struct sock *__sk_head(const struct hlist_head *head)
 {
 	return hlist_entry(head->first, struct sock, sk_node);
-- 
1.6.3

