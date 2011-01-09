From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 4/6] net/sock.h: make some fields private to fix kernel-doc
 warning(s)
Date: Sat, 8 Jan 2011 19:39:21 -0800
Message-ID: <20110108193921.e03ca09e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: lkml <linux-kernel@vger.kernel.org>,
	Linus <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix new kernel-doc notation warning in sock.h by annotating skc_dontcopy_*
as private fields.

Warning(include/net/sock.h:163): No description found for parameter 'skc_dontcopy_end[0]'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/net/sock.h |    4 ++++
 1 file changed, 4 insertions(+)

--- lnx0107.orig/include/net/sock.h
+++ lnx0107/include/net/sock.h
@@ -152,14 +152,18 @@ struct sock_common {
 	 * fields between dontcopy_begin/dontcopy_end
 	 * are not copied in sock_copy()
 	 */
+	/* private: */
 	int			skc_dontcopy_begin[0];
+	/* public: */
 	union {
 		struct hlist_node	skc_node;
 		struct hlist_nulls_node skc_nulls_node;
 	};
 	int			skc_tx_queue_mapping;
 	atomic_t		skc_refcnt;
+	/* private: */
 	int                     skc_dontcopy_end[0];
+	/* public: */
 };
 
 /**
