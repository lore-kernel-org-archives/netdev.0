From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Tue, 24 May 2016 14:57:06 +0300
Message-ID: <20160524145706-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
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

The following changes since commit 2dcd0af568b0cf583645c8a317dd12e344b1c72a:

  Linux 4.6 (2016-05-15 15:43:13 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to bb991288728e6a47a6f0fac6a4e9dfaeecc27956:

  ringtest: pass buf != NULL (2016-05-22 19:44:14 +0300)

----------------------------------------------------------------
virtio: patches for 4.7

Looks like a quiet cycle for virtio.  There's a new inorder option for the
ringtest tool, and a bugfix for balloon for ppc platforms when using virtio 1
mode.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Michael S. Tsirkin (3):
      virtio: add inorder option
      virtio_balloon: fix PFN format for virtio-1
      ringtest: pass buf != NULL

 drivers/virtio/virtio_balloon.c             | 20 +++++++-----
 tools/virtio/ringtest/main.c                |  2 +-
 tools/virtio/ringtest/virtio_ring_0_9.c     | 49 ++++++++++++++++++++++++++++-
 tools/virtio/ringtest/virtio_ring_inorder.c |  2 ++
 tools/virtio/ringtest/Makefile              |  5 ++-
 5 files changed, 67 insertions(+), 11 deletions(-)
 create mode 100644 tools/virtio/ringtest/virtio_ring_inorder.c
