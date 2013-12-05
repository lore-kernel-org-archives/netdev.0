From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 0/2] virtio-net: Fix two bugs on unloading the module
Date: Thu,  5 Dec 2013 18:36:19 +0400
Message-ID: <1386254181-17257-1-git-send-email-avagin@openvz.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: virtualization@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

They can be easy to reproduce, if you try to unload virtio-net

Andrey Vagin (2):
  virtio-net: determine type of bufs correctly
  virtio: delete napi objects from netdev before releasing memory

 drivers/net/virtio_net.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
-- 
1.8.3.1
