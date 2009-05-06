From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix build regression from address list changes.
Date: Wed, 06 May 2009 15:44:44 -0700 (PDT)
Message-ID: <20090506.154444.266197851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42458
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751098AbZEFWot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:44:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm about to push the following out to net-next-2.6, just FYI:

net: Add missing rculist.h include to netdevice.h

Otherwise list_for_each_entry_rcu() et al. aren't visible
and we get build failures in some configurations.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 02882e2..2af89b6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -39,6 +39,7 @@
 
 #include <linux/device.h>
 #include <linux/percpu.h>
+#include <linux/rculist.h>
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
 
