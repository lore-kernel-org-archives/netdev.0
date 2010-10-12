From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [RFC arm-kernel 1/4] caif-u5500: Adding shared memory include
Date: Tue, 12 Oct 2010 13:10:18 +0200
Message-ID: <1286881821-2916-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1286881821-2916-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stefan.xk.nilsson@stericsson.com, linus.walleij@stericsson.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kim.lilliestierna@stericsson.com, daniel.martensson@stericsson.com,
	Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54277 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757240Ab0JLLKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 07:10:54 -0400
Received: by ewy20 with SMTP id 20so1136107ewy.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 04:10:53 -0700 (PDT)
In-Reply-To: <1286881821-2916-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
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
+ * Author: Amarnath Revanna / amarnath.bangalore.revanna@stericsson.co=
m
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
--=20
1.7.0.4

