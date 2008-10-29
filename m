From: Joe Perches <joe@perches.com>
Subject: [ofa-general] ***SPAM*** [PATCH] infiniband: Add struct in6_addr
	addr to union ib_gib
Date: Tue, 28 Oct 2008 17:16:14 -0700
Message-ID: <1225239374.5269.251.camel@localhost>
References: <1225229901.11483.58.camel@brick>
	<1225234963.5269.228.camel@localhost>  <ada8ws8mi8x.fsf@cisco.com>
	<1225236128.5269.240.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	general@lists.openfabrics.org, Sean Hefty <sean.hefty@intel.com>,
	Harvey Harrison <harvey.harrison@gmail.com>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1225236128.5269.240.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

ib_gid's can be print'd using the new %p6 facility

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 936e333..464ed9d 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -47,6 +47,7 @@
 #include <linux/list.h>
 #include <linux/rwsem.h>
 #include <linux/scatterlist.h>
+#include <linux/in6.h>
 
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
@@ -57,6 +58,7 @@ union ib_gid {
 		__be64	subnet_prefix;
 		__be64	interface_id;
 	} global;
+	struct in6_addr	addr;
 };
 
 enum rdma_node_type {
