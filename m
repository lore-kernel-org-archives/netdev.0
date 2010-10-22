From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [PATCH 1/4] caif-u5500: Adding shared memory include
Date: Fri, 22 Oct 2010 21:03:52 +0200
Message-ID: <1287774235-11151-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1287774235-11151-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: stefan.xk.nilsson@stericsson.com, linus.walleij@stericsson.com,
	sjurbr@gmail.com,
	Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: Russel King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-reply-to: <1287774235-11151-1-git-send-email-sjur.brandeland@stericsson.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_shm.h |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)
 create mode 100644 include/net/caif/caif_shm.h

diff --git a/include/net/caif/caif_shm.h b/include/net/caif/caif_shm.h
new file mode 100644
index 0000000..5bcce55
--- /dev/null
+++ b/include/net/caif/caif_shm.h
@@ -0,0 +1,26 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
+ * Author: Amarnath Revanna / amarnath.bangalore.revanna@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_SHM_H_
+#define CAIF_SHM_H_
+
+struct shmdev_layer {
+	u32 shm_base_addr;
+	u32 shm_total_sz;
+	u32 shm_id;
+	u32 shm_loopback;
+	void *hmbx;
+	int (*pshmdev_mbxsend) (u32 shm_id, u32 mbx_msg);
+	int (*pshmdev_mbxsetup) (void *pshmdrv_cb,
+				struct shmdev_layer *pshm_dev, void *pshm_drv);
+	struct net_device *pshm_netdev;
+};
+
+extern int caif_shmcore_probe(struct shmdev_layer *pshm_dev);
+extern void caif_shmcore_remove(struct net_device *pshm_netdev);
+
+#endif
-- 
1.6.3.3
