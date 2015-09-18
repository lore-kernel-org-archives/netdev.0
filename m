From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Fri, 18 Sep 2015 13:42:53 +0300
Message-ID: <20150918134253-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cornelia.huck@de.ibm.com, mst@redhat.com, pmorel@linux.vnet.ibm.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 997e120843e82609c8d99a9d5714e6cf91e14cbe:

  virtio_balloon: do not change memory amount visible via /proc/meminfo (2015-09-08 13:32:11 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to ad2aa04218de9bd734d593adb0ac59854ec0cb68:

  virtio/s390: handle failures of READ_VQ_CONF ccw (2015-09-16 12:48:08 +0300)

----------------------------------------------------------------
virtio: fixes on top of 4.3-rc1

This fixes the virtio-test tool, and improves
the error handling for virtio-ccw.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Michael S. Tsirkin (3):
      tools/virtio: fix build after 4.2 changes
      vhost: move features to core
      tools/virtio: propagate V=X to kernel build

Pierre Morel (1):
      virtio/s390: handle failures of READ_VQ_CONF ccw

 drivers/vhost/vhost.h            |  4 +++-
 tools/virtio/asm/barrier.h       |  2 ++
 tools/virtio/linux/export.h      |  3 +++
 tools/virtio/linux/kernel.h      |  8 ++++++++
 drivers/s390/virtio/virtio_ccw.c | 10 +++++++++-
 drivers/vhost/net.c              |  3 +--
 drivers/vhost/scsi.c             |  4 +---
 drivers/vhost/test.c             |  3 +++
 tools/virtio/Makefile            |  2 +-
 9 files changed, 31 insertions(+), 8 deletions(-)
 create mode 100644 tools/virtio/linux/export.h
