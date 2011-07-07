From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next] net: fix warning of versioncheck
Date: Thu, 07 Jul 2011 11:08:21 +0800
Message-ID: <4E152325.4050202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58579 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752769Ab1GGDHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2011 23:07:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net-next-2.6/drivers/net/bnx2x/bnx2x_sp.c: 19 linux/version.h not needed.
net-next-2.6/drivers/net/caif/caif_hsi.c: 9 linux/version.h not needed.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/bnx2x/bnx2x_sp.c |    1 -
 drivers/net/caif/caif_hsi.c  |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_sp.c b/drivers/net/bnx2x/bnx2x_sp.c
index 5bdf094..f6322a1 100644
--- a/drivers/net/bnx2x/bnx2x_sp.c
+++ b/drivers/net/bnx2x/bnx2x_sp.c
@@ -16,7 +16,6 @@
  * Written by: Vladislav Zolotarov
  *
  */
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/crc32.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 016108a..b41c2fc 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -6,7 +6,6 @@
  * License terms: GNU General Public License (GPL) version 2.
  */
 
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/device.h>
-- 
1.7.4.1
