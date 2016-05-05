From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio/qemu: fixes for 4.6
Date: Thu, 5 May 2016 16:04:55 +0300
Message-ID: <20160505160455-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dan.carpenter@oracle.com
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

The following changes since commit c3b46c73264b03000d1e18b22f5caf63332547c9:

  Linux 4.6-rc4 (2016-04-17 19:13:32 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to e00f7bd221292b318d4d09c3f0c2c8af9b1e5edf:

  virtio: Silence uninitialized variable warning (2016-05-01 15:50:08 +0300)

----------------------------------------------------------------
virtio/qemu: fixes for 4.6

A couple of fixes for virtio and for the new QEMU fw cfg driver.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Dan Carpenter (2):
      firmware: qemu_fw_cfg.c: potential unintialized variable
      virtio: Silence uninitialized variable warning

 drivers/firmware/qemu_fw_cfg.c | 2 +-
 drivers/virtio/virtio_ring.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
