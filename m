From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] vmxnet3: make local function static
Date: Fri, 22 Feb 2013 10:26:29 -0800
Message-ID: <20130222102629.6690bdca@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:43900 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114Ab3BVS0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 13:26:52 -0500
Received: by mail-pb0-f42.google.com with SMTP id xb4so542653pbc.29
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 10:26:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vmxnet3/vmxnet3_drv.c	2013-02-21 21:35:42.998296803 -0800
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c	2013-02-21 21:41:45.149613077 -0800
@@ -1385,8 +1385,8 @@ vmxnet3_rq_cleanup_all(struct vmxnet3_ad
 }
 
 
-void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
-			struct vmxnet3_adapter *adapter)
+static void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
+			       struct vmxnet3_adapter *adapter)
 {
 	int i;
 	int j;
