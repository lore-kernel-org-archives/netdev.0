From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 15/15] ieee1394: eth1394: check for
 kmem_cache_create failure
Date: Mon, 2 Apr 2007 02:25:04 +0200 (CEST)
Message-ID: <tkrat.8edd63b3cd27fc01@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:36964 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbXDBAZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2007 20:25:09 -0400
In-Reply-To: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Content-Disposition: INLINE
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -1676,6 +1676,8 @@ static int __init ether1394_init_module 
 	packet_task_cache = kmem_cache_create("packet_task",
 					      sizeof(struct packet_task),
 					      0, 0, NULL, NULL);
+	if (!packet_task_cache)
+		return -ENOMEM;
 
 	hpsb_register_highlevel(&eth1394_highlevel);
 	return hpsb_register_protocol(&eth1394_proto_driver);

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/

