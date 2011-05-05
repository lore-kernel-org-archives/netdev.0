From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 3/3] virtio_ring: need_event api comment fix
Date: Thu, 5 May 2011 18:08:17 +0300
Message-ID: <c8b6d8a8df4927826d0024fceeb68726c50d0b1a.1304605817.git.mst@redhat.com>
References: <cover.1304605816.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Carsten Otte <cotte@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Shirley Ma <xma@us.ibm.com>, lguest@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, kvm@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, steved@us.ibm.com,
	habanero@linux.vnet.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45084 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754409Ab1EEPJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 11:09:15 -0400
Content-Disposition: inline
In-Reply-To: <cover.1304605816.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix typo in a comment: size -> side

Reported-by: Stefan Hajnoczi <stefanha@gmail.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/virtio_ring.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/virtio_ring.h b/include/linux/virtio_ring.h
index 089cbf2..0a45c6e 100644
--- a/include/linux/virtio_ring.h
+++ b/include/linux/virtio_ring.h
@@ -131,7 +131,7 @@ static inline unsigned vring_size(unsigned int num, unsigned long align)
 }
 
 /* The following is used with USED_EVENT_IDX and AVAIL_EVENT_IDX */
-/* Assuming a given event_idx value from the other size, if
+/* Assuming a given event_idx value from the other side, if
  * we have just incremented index from old to new_idx,
  * should we trigger an event? */
 static inline int vring_need_event(__u16 event_idx, __u16 new_idx, __u16 old)
-- 
1.7.5.53.gc233e
