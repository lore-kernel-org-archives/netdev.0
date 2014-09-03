From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 0/3] virtio: simplify virtio_ring.
Date: Wed,  3 Sep 2014 13:59:13 +0930
Message-ID: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
Cc: Andy Lutomirski <luto@amacapital.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:55752 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbaICEaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 00:30:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I resurrected these patches after prompting from Andy Lutomirski's
recent patches.  I put them on the back-burner because vring_bench
had a 15% slowdown on my laptop: pktgen testing revealed a speedup,
if anything, so I've cleaned them up.

Rusty Russell (3):
  virtio_net: pass well-formed sgs to virtqueue_add_*()
  virtio_ring: assume sgs are always well-formed.
  virtio_ring: unify direct/indirect code paths.

 drivers/net/virtio_net.c     |   5 +-
 drivers/virtio/virtio_ring.c | 185 +++++++++++++++----------------------------
 2 files changed, 69 insertions(+), 121 deletions(-)

-- 
1.9.1
