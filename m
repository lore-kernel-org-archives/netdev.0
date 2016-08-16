From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: fixes for 4.8
Date: Tue, 16 Aug 2016 17:37:04 +0300
Message-ID: <20160816173704-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, stefanha@redhat.com,
	ggarcia@abra.uab.cat
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

The following changes since commit 3b2fbb3f06efe5bd2dfdce2a1db703e23c1a78af:

  virtio/s390: deprecate old transport (2016-08-09 13:42:41 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 6be3ffaa0e15c64f560904b025f5c50bef5886f9:

  tools/virtio: add dma stubs (2016-08-15 05:05:51 +0300)

----------------------------------------------------------------
virtio/vhost: fixes for 4.8

- Test fixes.
- A vsock fix.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Gerard Garcia (1):
      vhost/vsock: drop space available check for TX vq

Michael S. Tsirkin (3):
      ringtest: test build fix
      vhost/test: fix after swiotlb changes
      tools/virtio: add dma stubs

 tools/virtio/linux/dma-mapping.h   | 16 ++++++++++++++++
 tools/virtio/linux/kernel.h        | 14 ++++++++++++++
 tools/virtio/linux/slab.h          |  4 ++++
 tools/virtio/linux/virtio.h        |  6 +++++-
 tools/virtio/linux/virtio_config.h | 13 +++++++++++++
 drivers/vhost/test.c               |  8 ++++----
 net/vmw_vsock/virtio_transport.c   | 10 +++-------
 tools/virtio/ringtest/ptr_ring.c   |  1 +
 8 files changed, 60 insertions(+), 12 deletions(-)
