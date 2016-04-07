From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio/qemu: fixes for 4.6
Date: Thu, 7 Apr 2016 20:07:33 +0300
Message-ID: <20160407200733-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, stefanha@redhat.com,
	gregkh@linuxfoundation.org, somlo@cmu.edu
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

The following changes since commit 9735a22799b9214d17d3c231fe377fc852f042e9:

  Linux 4.6-rc2 (2016-04-03 09:09:40 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to c00bbcf8628969e103d4a7b351a53746f1025576:

  virtio: add VIRTIO_CONFIG_S_NEEDS_RESET device status bit (2016-04-07 15:16:41 +0300)

----------------------------------------------------------------
virtio/qemu: fixes for 4.6

A couple of fixes for virtio and for the new QEMU fw cfg driver.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Gabriel Somlo (1):
      firmware: qemu_fw_cfg.c: hold ACPI global lock during device access

Michael S. Tsirkin (3):
      qemu_fw_cfg: don't leak kobj on init error
      virtio: virtio 1.0 cs04 spec compliance for reset
      MAINTAINERS: add entry for QEMU

Stefan Hajnoczi (1):
      virtio: add VIRTIO_CONFIG_S_NEEDS_RESET device status bit

 include/uapi/linux/virtio_config.h |  2 ++
 drivers/firmware/qemu_fw_cfg.c     | 24 +++++++++++++++++++++++-
 drivers/virtio/virtio_pci_modern.c | 11 ++++++++---
 MAINTAINERS                        |  7 +++++++
 4 files changed, 40 insertions(+), 4 deletions(-)
