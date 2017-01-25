From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio, vhost: fixes
Date: Wed, 25 Jan 2017 18:21:18 +0200
Message-ID: <20170125182118-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, will.deacon@arm.com,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, marc.zyngier@arm.com,
	luto@kernel.org, robin.murphy@arm.com
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

The following changes since commit 7a308bb3016f57e5be11a677d15b821536419d36:

  Linux 4.10-rc5 (2017-01-22 12:54:15 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to c7070619f3408d9a0dffbed9149e6f00479cf43b:

  vring: Force use of DMA API for ARM-based systems with legacy devices (2017-01-25 00:33:11 +0200)

----------------------------------------------------------------
virtio, vhost: fixes

ARM DMA fixes
vhost vsock bugfix

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Robin Murphy (1):
      virtio_mmio: Set DMA masks appropriately

Stefan Hajnoczi (1):
      vhost/vsock: handle vhost_vq_init_access() error

Will Deacon (1):
      vring: Force use of DMA API for ARM-based systems with legacy devices

 drivers/vhost/vsock.c        | 13 +++++++++----
 drivers/virtio/virtio_mmio.c | 20 +++++++++++++++++++-
 drivers/virtio/virtio_ring.c |  7 +++++++
 3 files changed, 35 insertions(+), 5 deletions(-)
