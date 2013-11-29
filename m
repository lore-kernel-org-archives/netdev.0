From: Thomas Huth <thuth@linux.vnet.ibm.com>
Subject: [PATCH] virtio_net: Fixed a trivial typo (fitler --> filter)
Date: Fri, 29 Nov 2013 10:02:19 +0100
Message-ID: <1385715739-12299-1-git-send-email-thuth@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, mst@redhat.com,
	trivial@kernel.org, Thomas Huth <thuth@linux.vnet.ibm.com>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:49271 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab3K2JC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 04:02:56 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <thuth@linux.vnet.ibm.com>;
	Fri, 29 Nov 2013 09:02:54 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9D1D02190059
	for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 09:02:51 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAT92dDE44171320
	for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 09:02:39 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAT92nTP016961
	for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 02:02:51 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"MAC filter" sounds more reasonable than "MAC fitler".

Signed-off-by: Thomas Huth <thuth@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 01f4eb5..fd96f09 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1075,7 +1075,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
 				  VIRTIO_NET_CTRL_MAC_TABLE_SET,
 				  sg, NULL))
-		dev_warn(&dev->dev, "Failed to set MAC fitler table.\n");
+		dev_warn(&dev->dev, "Failed to set MAC filter table.\n");
 
 	kfree(buf);
 }
-- 
1.7.1
