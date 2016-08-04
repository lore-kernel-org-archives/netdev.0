From: ggarcia@abra.uab.cat
Subject: [PATCH v2 0/1] virtio-vsock: Fix unbound rx buffer
Date: Thu, 04 Aug 2016 16:09:56 +0200
Message-ID: <20160804140957.23693-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:33900 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933762AbcHDOKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 10:10:38 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBE00E9920SC800@damascus.uab.es> for
 netdev@vger.kernel.org; Thu, 04 Aug 2016 16:10:05 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OBE00JN220SNS80@damascus.uab.es> for
 netdev@vger.kernel.org; Thu, 04 Aug 2016 16:10:04 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

This patch applies over VSOCK RFC v6.

Reset connection and close rx socket when the sender is ignoring our
announced available buffer. This avoids a DoS.

v2:
 * Get vvs->rx_lock lock before checking if next packet is going to
    overflow the rx buffer.

Gerard Garcia (1):
  Fix unbound rx buffer

 net/vmw_vsock/virtio_transport_common.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

-- 
2.9.1
