From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Mon, 23 Jan 2017 17:05:30 +0200
Message-ID: <20170123170530-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gcampana@quarkslab.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, pmorel@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dan.carpenter@oracle.com, colin.king@canonical.com,
	bhumirks@gmail.com, silbe@linux.vnet.ibm.com
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

The following changes since commit 49def1853334396f948dcb4cedb9347abb318df5:

  Linux 4.10-rc4 (2017-01-15 16:21:59 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 0db1dba5dfaf70fb3baf07973996db2078528cde:

  virtio/s390: virtio: constify virtio_config_ops structures (2017-01-19 23:46:34 +0200)

Note: ARM DMA fixes missed this pull, will be in the next one.

----------------------------------------------------------------
virtio, vhost: fixes, cleanups

Random fixes and cleanups that accumulated over the time.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Bhumika Goyal (2):
      vhost: scsi: constify target_core_fabric_ops structures
      virtio/s390: virtio: constify virtio_config_ops structures

Colin Ian King (1):
      virtio/s390: add missing \n to end of dev_err message

Dan Carpenter (1):
      vhost/scsi: silence uninitialized variable warning

G. Campana (1):
      virtio_console: fix a crash in config_work_handler

Halil Pasic (2):
      tools/virtio/ringtest: fix run-on-all.sh for offline cpus
      tools/virtio/ringtest: tweaks for s390

Pierre Morel (1):
      virtio/s390: support READ_STATUS command for virtio-ccw

 drivers/char/virtio_console.c       |  2 +-
 drivers/s390/virtio/virtio_ccw.c    | 29 +++++++++++++++++++++++++++--
 drivers/vhost/scsi.c                |  4 ++--
 tools/virtio/ringtest/main.h        | 12 ++++++++++++
 tools/virtio/ringtest/run-on-all.sh |  5 +++--
 5 files changed, 45 insertions(+), 7 deletions(-)
