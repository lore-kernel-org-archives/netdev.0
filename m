From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: fixes and cleanups for 4.8
Date: Thu, 11 Aug 2016 21:31:40 +0300
Message-ID: <20160811213140-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@oracle.com, weiyj.lk@gmail.com, stefanha@redhat.com,
	kvm@vger.kernel.org, minfei.hmf@alibaba-inc.com,
	netdev@vger.kernel.org, fanc.fnst@cn.fujitsu.com,
	liujbjl@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, mst@redhat.com,
	viro@zeniv.linux.org.uk, mnghuan@gmail.com, dan.carpenter@oracle.com
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

The following changes since commit 29b4817d4018df78086157ea3a55c1d9424a7cfc:

  Linux 4.8-rc1 (2016-08-07 18:18:00 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 3b2fbb3f06efe5bd2dfdce2a1db703e23c1a78af:

  virtio/s390: deprecate old transport (2016-08-09 13:42:41 +0300)

----------------------------------------------------------------
virtio/vhost: fixes and cleanups for 4.8

- Misc fixes and cleanups all over the place.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Christian Borntraeger (1):
      virtio/s390: keep early_put_chars

Cornelia Huck (1):
      virtio/s390: deprecate old transport

Michael S. Tsirkin (1):
      virtio: fix error handling for debug builds

Minfei Huang (1):
      virtio_blk: Fix a slient kernel panic

Stefan Hajnoczi (2):
      vhost/vsock: fix vhost virtio_vsock_pkt use-after-free
      virtio-vsock: fix include guard typo

Vegard Nossum (1):
      9p/trans_virtio: use kvfree() for iov_iter_get_pages_alloc()

Wei Yongjun (1):
      virtio: fix memory leak in virtqueue_add()

 include/uapi/linux/virtio_vsock.h |  2 +-
 drivers/block/virtio_blk.c        | 26 ++++++++------------------
 drivers/s390/virtio/kvm_virtio.c  |  4 +++-
 drivers/vhost/vsock.c             |  6 +++++-
 drivers/virtio/virtio_ring.c      |  3 +++
 net/9p/trans_virtio.c             |  4 ++--
 arch/s390/Kconfig                 | 13 +++++++++++++
 drivers/s390/virtio/Makefile      |  6 +++++-
 8 files changed, 40 insertions(+), 24 deletions(-)
