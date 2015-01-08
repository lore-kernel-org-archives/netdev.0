From: "Michael S. Tsirkin" <mst@kernel.org>
Subject: [PULL] vhost: cleanups and fixes
Date: Thu, 8 Jan 2015 09:51:41 +0200
Message-ID: <20150108075141.GA11915@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, sasha.levin@oracle.com
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

The following changes since commit b1940cd21c0f4abdce101253e860feff547291b0:

  Linux 3.19-rc3 (2015-01-05 17:05:20 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 99975cc6ada0d5f2675e83abecae05aba5f437d2:

  vhost/net: length miscalculation (2015-01-07 12:22:00 +0200)

----------------------------------------------------------------
virtio, vhost fixes for 3.19

This fixes a couple of bugs triggered by hot-unplug
of virtio devices, as well as a regression in vhost-net.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Michael S. Tsirkin (4):
      virtio: make del_vqs idempotent
      virtio_pci: device-specific release callback
      virtio_pci: document why we defer kfree
      vhost/net: length miscalculation

Sasha Levin (1):
      virtio_pci: defer kfree until release callback

 drivers/virtio/virtio_pci_common.h |  1 -
 drivers/vhost/net.c                |  2 +-
 drivers/virtio/virtio_pci_common.c | 10 +---------
 drivers/virtio/virtio_pci_legacy.c | 12 +++++++++++-
 4 files changed, 13 insertions(+), 12 deletions(-)
