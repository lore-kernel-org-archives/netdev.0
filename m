From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio: fixes, tests
Date: Wed, 27 Jan 2016 21:12:16 +0200
Message-ID: <20160127211216-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmarchan@redhat.com, kamal@canonical.com, mst@redhat.com,
	sasha.levin@oracle.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 92e963f50fc74041b5e9e744c330dca48e04f08d:

  Linux 4.5-rc1 (2016-01-24 13:06:47 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 481eaec37e91e2b33f17275901172f50ce2c71e8:

  tools/virtio: add ringtest utilities (2016-01-26 10:18:30 +0200)

----------------------------------------------------------------
virtio: fixes, tests

This fixes existing tests broken by barrier rework,
and adds some new tests.
Plus, there's a fix for an old bug in virtio-pci.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Michael S. Tsirkin (4):
      virtio_pci: fix use after free on release
      tools/virtio: use virt_xxx barriers
      sh: fix smp_store_mb for !SMP
      tools/virtio: add ringtest utilities

 arch/sh/include/asm/barrier.h            |   1 -
 tools/virtio/asm/barrier.h               |  22 +-
 tools/virtio/linux/compiler.h            |   9 +
 tools/virtio/linux/kernel.h              |   1 +
 tools/virtio/ringtest/main.h             | 119 ++++++++++
 drivers/virtio/virtio_pci_common.c       |   2 +
 tools/virtio/ringtest/main.c             | 366 +++++++++++++++++++++++++++++++
 tools/virtio/ringtest/ring.c             | 272 +++++++++++++++++++++++
 tools/virtio/ringtest/virtio_ring_0_9.c  | 316 ++++++++++++++++++++++++++
 tools/virtio/ringtest/virtio_ring_poll.c |   2 +
 tools/virtio/ringtest/Makefile           |  22 ++
 tools/virtio/ringtest/README             |   2 +
 tools/virtio/ringtest/run-on-all.sh      |  24 ++
 13 files changed, 1148 insertions(+), 10 deletions(-)
 create mode 100644 tools/virtio/linux/compiler.h
 create mode 100644 tools/virtio/ringtest/main.h
 create mode 100644 tools/virtio/ringtest/main.c
 create mode 100644 tools/virtio/ringtest/ring.c
 create mode 100644 tools/virtio/ringtest/virtio_ring_0_9.c
 create mode 100644 tools/virtio/ringtest/virtio_ring_poll.c
 create mode 100644 tools/virtio/ringtest/Makefile
 create mode 100644 tools/virtio/ringtest/README
 create mode 100755 tools/virtio/ringtest/run-on-all.sh
