From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-next-2.6] vhost-net: tools, cleanups, optimizations
Date: Mon, 13 Dec 2010 12:44:13 +0200
Message-ID: <20101213104413.GA678@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please merge the following tree for 2.6.38.
Thanks!

The following changes since commit ad1184c6cf067a13e8cb2a4e7ccc407f947027d0:

  net: au1000_eth: remove unused global variable. (2010-12-11 12:01:48 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

Jason Wang (1):
      vhost: fix typos in comment

Julia Lawall (1):
      drivers/vhost/vhost.c: delete double assignment

Michael S. Tsirkin (9):
      vhost: put mm after thread stop
      vhost-net: batch use/unuse mm
      vhost: copy_to_user -> __copy_to_user
      vhost: get/put_user -> __get/__put_user
      vhost: remove unused include
      vhost: correctly set bits of dirty pages
      vhost: better variable name in logging
      vhost test module
      tools/virtio: virtio_test tool

 drivers/vhost/net.c                  |    9 +-
 drivers/vhost/test.c                 |  320 ++++++++++++++++++++++++++++++++++
 drivers/vhost/test.h                 |    7 +
 drivers/vhost/vhost.c                |   44 +++---
 drivers/vhost/vhost.h                |    2 +-
 tools/virtio/Makefile                |   12 ++
 tools/virtio/linux/device.h          |    2 +
 tools/virtio/linux/slab.h            |    2 +
 tools/virtio/linux/virtio.h          |  223 +++++++++++++++++++++++
 tools/virtio/vhost_test/Makefile     |    2 +
 tools/virtio/vhost_test/vhost_test.c |    1 +
 tools/virtio/virtio_test.c           |  248 ++++++++++++++++++++++++++
 12 files changed, 842 insertions(+), 30 deletions(-)
 create mode 100644 drivers/vhost/test.c
 create mode 100644 drivers/vhost/test.h
 create mode 100644 tools/virtio/Makefile
 create mode 100644 tools/virtio/linux/device.h
 create mode 100644 tools/virtio/linux/slab.h
 create mode 100644 tools/virtio/linux/virtio.h
 create mode 100644 tools/virtio/vhost_test/Makefile
 create mode 100644 tools/virtio/vhost_test/vhost_test.c
 create mode 100644 tools/virtio/virtio_test.c
