From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 3/9] fs_enet: Include linux/string.h from linux/fs_enet_pd.h
Date: Mon, 1 Oct 2007 14:20:49 -0500
Message-ID: <20071001192049.GB28429@loki.buserror.net>
References: <20071001192017.GA28410@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:47628 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbXJATVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 15:21:10 -0400
Content-Disposition: inline
In-Reply-To: <20071001192017.GA28410@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is needed for strstr().

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 include/linux/fs_enet_pd.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
index 543cd3c..815c6f9 100644
--- a/include/linux/fs_enet_pd.h
+++ b/include/linux/fs_enet_pd.h
@@ -16,6 +16,7 @@
 #ifndef FS_ENET_PD_H
 #define FS_ENET_PD_H
 
+#include <linux/string.h>
 #include <asm/types.h>
 
 #define FS_ENET_NAME	"fs_enet"
-- 
1.5.3.2

