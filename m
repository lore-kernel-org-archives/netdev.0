From: ggarcia@abra.uab.cat
Subject: [PATCH v3 0/1] virtio-vsock: Add timer to handle OOM situations
Date: Tue, 02 Aug 2016 19:23:25 +0200
Message-ID: <20160802172326.1220-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:62070 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932548AbcHBRXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 13:23:54 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBA00FYXLNQLQ00@damascus.uab.es> for
 netdev@vger.kernel.org; Tue, 02 Aug 2016 19:23:50 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBA00HHKLNQLP00@damascus.uab.es> for
 netdev@vger.kernel.org; Tue, 02 Aug 2016 19:23:50 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

This patch applies over VSOCK RFC v6.

Once the guest puts a packet in the virtqueue it is guaranteed
that it will be delivered.

This patch addresses the problem of packets being discarded when
there is not available memory in the host.

Gerard Garcia (1):
  Add timer to handle OOM situations

 drivers/vhost/vsock.c | 52 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 10 deletions(-)

-- 
2.9.1
