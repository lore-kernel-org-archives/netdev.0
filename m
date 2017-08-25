From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Fri, 25 Aug 2017 21:47:19 +0300
Message-ID: <20170825214719-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, stefanha@redhat.com,
	yasu.isimatu@gmail.com, hch@lst.de
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

The following changes since commit 14ccee78fc82f5512908f4424f541549a5705b89:

  Linux 4.13-rc6 (2017-08-20 14:13:52 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to ba74b6f7fcc07355d087af6939712eed4a454821:

  virtio_pci: fix cpu affinity support (2017-08-25 21:38:26 +0300)

----------------------------------------------------------------
virtio: bugfix

Fixes two obvious bugs in virtio pci.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Christoph Hellwig (1):
      virtio_pci: fix cpu affinity support

Stefan Hajnoczi (1):
      virtio_blk: fix incorrect message when disk is resized

 drivers/block/virtio_blk.c         | 16 ++++++++++------
 drivers/virtio/virtio_pci_common.c | 10 +++++++---
 2 files changed, 17 insertions(+), 9 deletions(-)
