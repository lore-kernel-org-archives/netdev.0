From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 2/3] vxge: use strcpy for strings
Date: Mon, 29 Nov 2010 22:02:46 -0600
Message-ID: <1291089767-18864-2-git-send-email-jon.mason@exar.com>
References: <1291089767-18864-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:43931 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545Ab0K3EDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:03:02 -0500
Received: by ywl5 with SMTP id 5so2478953ywl.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 20:03:01 -0800 (PST)
In-Reply-To: <1291089767-18864-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use strncpy instead of memcpy when working on strings

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/vxge/vxge-main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 44129c3..8a84152 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3451,7 +3451,7 @@ static void vxge_device_unregister(struct __vxge_hw_device *hldev)
 	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d", vdev->ndev->name,
 			     __func__, __LINE__);
 
-	memcpy(buf, dev->name, IFNAMSIZ);
+	strncpy(buf, dev->name, IFNAMSIZ);
 
 	/* in 2.6 will call stop() if device is up */
 	unregister_netdev(dev);
-- 
1.7.0.4

