From: ggarcia@abra.uab.cat
Subject: [PATCH 0/1] virtio-vsock: Fix unbound rx buffer
Date: Mon, 01 Aug 2016 19:18:20 +0200
Message-ID: <20160801171821.32662-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: stefanha@redhat.com, Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:63438 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754721AbcHARTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 13:19:17 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OB8000DEQQPHF00@damascus.uab.es> for
 netdev@vger.kernel.org; Mon, 01 Aug 2016 19:18:25 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0OB800CWEQQPUY20@damascus.uab.es> for
 netdev@vger.kernel.org; Mon, 01 Aug 2016 19:18:25 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

This patch applies over VSOCK RFC v6.

Reset connection and close rx socket when the sender is ignoring our
announced available buffer. This avoids a DoS.

Gerard Garcia (1):
  Fix unbound rx buffer

 net/vmw_vsock/virtio_transport_common.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

-- 
2.9.1
