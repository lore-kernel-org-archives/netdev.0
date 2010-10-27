From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 1/4] caif-u5500: Adding shared memory include
Date: Wed, 27 Oct 2010 20:34:39 +0200
Message-ID: <1288204482-2742-1-git-send-email-sjur.brandeland@stericsson.com>
References: <20101027.110732.48492064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Russel King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, linus.walleij@stericsson.com,
	stefan.xk.nilsson@stericsson.com,
	Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:41187 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754915Ab0J0SfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:35:02 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LAY00A0ZOYCL960@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 27 Oct 2010 20:35:00 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.37])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LAY0006ZOYBC7A0@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 27 Oct 2010 20:35:00 +0200 (CEST)
In-reply-to: <20101027.110732.48492064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

