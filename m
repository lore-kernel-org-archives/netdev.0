From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 1/4] list: introduce list_is_first()
Date: Thu, 10 Dec 2015 22:17:15 +0800
Message-ID: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Seth Jennings <sjenning@redhat.com>,
	Jiri Kosina <jikos@kernel.org>,
	Vojtech Pavlik <vojtech@suse.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Jens Axboe <axboe@kernel.dk>, live-patching@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>,
	Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We already have list_is_last(), it makes sense to also add
list_is_first() for consistency. This list utility function
to check for first element in a list.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 include/linux/list.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/list.h b/include/linux/list.h
index 5356f4d..2c43ef4 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -170,6 +170,17 @@ static inline void list_move_tail(struct list_head *list,
 }
 
 /**
+ * list_is_first - tests whether @list is the first entry in list @head
+ * @list: the entry to test
+ * @head: the head of the list
+ */
+static inline int list_is_first(const struct list_head *list,
+				const struct list_head *head)
+{
+	return list->prev == head;
+}
+
+/**
  * list_is_last - tests whether @list is the last entry in list @head
  * @list: the entry to test
  * @head: the head of the list
-- 
2.5.0
