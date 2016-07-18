From: ggarcia@abra.uab.cat
Subject: [PATCH] virtio-vsock: Add timer to handle OOM situations
Date: Mon, 18 Jul 2016 17:11:02 +0200
Message-ID: <20160718151103.15076-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:49692 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751320AbcGRPLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 11:11:10 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OAI0070ZNIJFR30@damascus.uab.es> for
 netdev@vger.kernel.org; Mon, 18 Jul 2016 17:11:07 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OAI00BOANIJXJN2@damascus.uab.es> for
 netdev@vger.kernel.org; Mon, 18 Jul 2016 17:11:07 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

This patch applies over the stefanha/vsock-next repository:
https://github.com/stefanha/linux/tree/vsock-next

Once the guest puts a packet in the virtqueue it is guaranteed
that it will be delivered. 

This patch addresses the problem of packets being discarded when 
there is not available memory in the host.

Gerard Garcia (1):
  Add timer to handle OOM situations

 drivers/vhost/vsock.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 47 insertions(+), 5 deletions(-)

-- 
2.9.1
