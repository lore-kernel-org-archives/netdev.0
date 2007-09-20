From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 2/9] fs_enet: Include linux/string.h from linux/fs_enet_pd.h
Date: Thu, 20 Sep 2007 17:01:17 -0500
Message-ID: <20070920220117.GB28784@loki.buserror.net>
References: <20070920220043.GA28769@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:47789 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbXITWBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 18:01:53 -0400
Content-Disposition: inline
In-Reply-To: <20070920220043.GA28769@loki.buserror.net>
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
1.5.3.1

