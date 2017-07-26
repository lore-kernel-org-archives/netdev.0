From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: fixes, cleanups
Date: Wed, 26 Jul 2017 19:11:34 +0300
Message-ID: <20170726191134-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andriy.shevchenko@linux.intel.com, bigeasy@linutronix.de,
        drjones@redhat.com, jasowang@redhat.com, liang.z.li@intel.com,
        mst@redhat.com, wei.w.wang@intel.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All's quiet here this cycle, just some minor fixes.  A block printk
message bugfix is still pending for the next pull, didn't want to delay
this one as people are getting impatient.

The following changes since commit 520eccdfe187591a51ea9ab4c1a024ae4d0f68d9:

  Linux 4.13-rc2 (2017-07-23 16:15:17 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to cfa0ebc9d6d6308564f5174ecb655b9d504b2be5:

  virtio-net: fix module unloading (2017-07-25 16:37:36 +0300)

----------------------------------------------------------------
virtio: fixes, cleanups

Fixes some minor issues all over the codebase.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Andrew Jones (1):
      virtio-net: fix module unloading

Andy Shevchenko (1):
      virtio_blk: Use sysfs_match_string() helper

Liang Li (1):
      virtio-balloon: deflate via a page list

Wei Wang (1):
      virtio-balloon: coding format cleanup

 drivers/block/virtio_blk.c      |  7 ++-----
 drivers/net/virtio_net.c        |  2 +-
 drivers/virtio/virtio_balloon.c | 28 ++++++++++++----------------
 3 files changed, 15 insertions(+), 22 deletions(-)
