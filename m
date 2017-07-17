From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 0/5] refine virtio-net XDP
Date: Mon, 17 Jul 2017 20:43:56 +0800
Message-ID: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
To: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

This series brings two optimizations for virtio-net XDP:

- avoid reset during XDP set
- turn off offloads on demand

Please review.

Thanks

Jason Wang (5):
  virtio_ring: allow to store zero as the ctx
  virtio-net: pack headroom into ctx for mergeable buffer
  virtio-net: switch to use new ctx API for small buffer
  virtio-net: do not reset during XDP set
  virtio-net: switch off offloads on demand if possible on XDP set

 drivers/net/virtio_net.c     | 325 +++++++++++++++++++++++++------------------
 drivers/virtio/virtio_ring.c |   2 +-
 2 files changed, 194 insertions(+), 133 deletions(-)

-- 
2.7.4
