From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC 0/2] virtio-net: implement reset request
Date: Tue, 29 Aug 2017 16:07:57 -0400
Message-ID: <20170829200759.13975-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:32944 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdH2UID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:08:03 -0400
Received: by mail-qk0-f193.google.com with SMTP id k126so413628qkb.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:08:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Implement VIRTIO_CONFIG_S_NEEDS_RESET (patch 1) and
add a feature bit to signal support (patch 2)

Further details in the individual patches.

Willem de Bruijn (2):
  virtio_net: implement VIRTIO_CONFIG_S_NEEDS_RESET
  virtio_net: enable probing for NEEDS_RESET support

 drivers/net/virtio_net.c           | 71 +++++++++++++++++++++++++++++++++-----
 include/uapi/linux/virtio_config.h |  3 ++
 include/uapi/linux/virtio_net.h    |  4 +++
 3 files changed, 69 insertions(+), 9 deletions(-)

-- 
2.14.1.342.g6490525c54-goog
