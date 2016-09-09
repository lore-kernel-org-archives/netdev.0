From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio: fixes for 4.8
Date: Sat, 10 Sep 2016 00:48:55 +0300
Message-ID: <20160910004855-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, arnd@arndb.de, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, luto@kernel.org,
	baoyou.xie@linaro.org
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

The following changes since commit 3eab887a55424fc2c27553b7bfe32330df83f7b8:

  Linux 4.8-rc4 (2016-08-28 15:04:33 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 5e59d9a1aed26abcc79abe78af5cfd34e53cbe7f:

  virtio_console: Stop doing DMA on the stack (2016-09-09 21:12:45 +0300)

----------------------------------------------------------------
virtio: fixes for 4.8

This includes a couple of bugfixs for virtio.

The virtio console patch is actually also
in x86/tip targeting 4.9 because it helps vmap
stacks, but it also fixes IOMMU_PLATFORM which
was added in 4.8, and it seems important not to
ship that in a broken configuration.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Andy Lutomirski (1):
      virtio_console: Stop doing DMA on the stack

Baoyou Xie (1):
      virtio: mark vring_dma_dev() static

 drivers/char/virtio_console.c | 23 +++++++++++++++--------
 drivers/virtio/virtio_ring.c  |  2 +-
 2 files changed, 16 insertions(+), 9 deletions(-)
