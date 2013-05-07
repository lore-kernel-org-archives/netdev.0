From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: more fixes for 3.10
Date: Tue, 7 May 2013 14:10:24 +0300
Message-ID: <20130507111024.GA18992@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pbonzini@redhat.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

I didn't do any back-merging tricks this time,
as a result this is behind master by quite a lot.
But I did a test merge and it came out correctly,
so this shouldn't be an issue.

The following changes since commit 181c04a357bb791587c55a99362c2fdde2c64f18:

  vhost_scsi: module rename (2013-05-02 13:40:22 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to a18cc421649dfdc21edb6c4c867dd05447d7df8c:

  vhost-scsi: Enable VIRTIO_RING_F_EVENT_IDX (2013-05-07 11:11:08 +0300)

----------------------------------------------------------------
vhost: more fixes for 3.10

This fixes some minor issues in the patches that have been merged.
We also finally drop the workaround disabling event_idx
for scsi: it was always questionable, and now we
know it's not needed.
There's also a memory leak fix.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Asias He (7):
      vhost: Export vhost_dev_set_owner
      vhost-net: Free ubuf when vhost_dev_set_owner fails
      vhost: Move VHOST_NET_FEATURES to net.c
      vhost: Remove comments for hdr in vhost.h
      vhost: Remove vhost_enable_zcopy in vhost.h
      vhost-net: Cleanup vhost_ubuf and vhost_zcopy
      vhost-scsi: Enable VIRTIO_RING_F_EVENT_IDX

Michael S. Tsirkin (1):
      vhost: drop virtio_net.h dependency

 drivers/vhost/net.c   | 100 +++++++++++++++++++++++++++++++++-----------------
 drivers/vhost/scsi.c  |   8 +---
 drivers/vhost/vhost.c |   4 +-
 drivers/vhost/vhost.h |  10 +----
 4 files changed, 71 insertions(+), 51 deletions(-)
