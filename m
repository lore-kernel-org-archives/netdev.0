From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 0/5] virtio 1.0 cleanups and one fix.
Date: Fri,  6 Feb 2015 15:36:51 +1030
Message-ID: <1423199216-2094-1-git-send-email-rusty@rustcorp.com.au>
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "lkml" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

	Some minor fixes for my virtio-next tree.  Michael, does
QEMU implement the (compuslory!) VIRTIO_PCI_CAP_PCI_CFG field?  I'm
guessing not, since it wasn't defined in the Linux header :(

Rusty Russell (5):
  virtio: define VIRTIO_PCI_CAP_PCI_CFG in header.
  virtio: Don't expose legacy block features when VIRTIO_BLK_NO_LEGACY
    defined.
  virtio: Don't expose legacy net features when VIRTIO_NET_NO_LEGACY
    defined.
  virtio: Don't expose legacy config features when
    VIRTIO_CONFIG_NO_LEGACY defined.
  virtio: don't require a config space on the console device.

 drivers/char/virtio_console.c      | 12 ++++++++----
 include/uapi/linux/virtio_blk.h    | 17 +++++++++++++----
 include/uapi/linux/virtio_config.h |  2 ++
 include/uapi/linux/virtio_net.h    | 30 ++++++++++++++++++++++++++++--
 include/uapi/linux/virtio_pci.h    |  4 +++-
 5 files changed, 54 insertions(+), 11 deletions(-)

-- 
2.1.0
