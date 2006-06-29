From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 7 of 39] IB/ipath - update some
 comments and fix typos
Date: Thu, 29 Jun 2006 14:40:58 -0700
Message-ID: <8f08597cacd2a9dcea28.1151617258@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org,
	rdreier@cisco.com,
	mst@mellanox.co.il
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Robert Walsh <robert.walsh@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r 600ceb6aeb8c -r 8f08597cacd2 drivers/infiniband/hw/ipath/ipath_kernel.h
--- a/drivers/infiniband/hw/ipath/ipath_kernel.h	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_kernel.h	Thu Jun 29 14:33:25 2006 -0700
@@ -723,13 +723,8 @@ u64 ipath_read_kreg64_port(const struct 
  * @port: port number
  *
  * Return the contents of a register that is virtualized to be per port.
- * Prints a debug message and returns -1 on errors (not distinguishable from
- * valid contents at runtime; we may add a separate error variable at some
- * point).
- *
- * This is normally not used by the kernel, but may be for debugging, and
- * has a different implementation than user mode, which is why it's not in
- * _common.h.
+ * Returns -1 on errors (not distinguishable from valid contents at
+ * runtime; we may add a separate error variable at some point).
  */
 static inline u32 ipath_read_ureg32(const struct ipath_devdata *dd,
 				    ipath_ureg regno, int port)
diff -r 600ceb6aeb8c -r 8f08597cacd2 drivers/infiniband/hw/ipath/ipath_layer.c
--- a/drivers/infiniband/hw/ipath/ipath_layer.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_layer.c	Thu Jun 29 14:33:25 2006 -0700
@@ -885,7 +885,7 @@ static void copy_io(u32 __iomem *piobuf,
 /**
  * ipath_verbs_send - send a packet from the verbs layer
  * @dd: the infinipath device
- * @hdrwords: the number of works in the header
+ * @hdrwords: the number of words in the header
  * @hdr: the packet header
  * @len: the length of the packet in bytes
  * @ss: the SGE to send
