From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 06/14] e1000e: remove unnecessary header file
	inclusions
Date: Fri, 21 Nov 2008 11:00:35 -0800
Message-ID: <20081121190035.32313.26432.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:59825 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753669AbYKUTAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:00:52 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

timer.h and workqueue.h do not need to be explicitly included.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c55fd6f..e09a181 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -32,8 +32,6 @@
 #define _E1000_H_
 
 #include <linux/types.h>
-#include <linux/timer.h>
-#include <linux/workqueue.h>
 #include <linux/io.h>
 #include <linux/netdevice.h>
 

